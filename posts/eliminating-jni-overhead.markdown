---
title: Eliminating JNI overhead: tricks and trade-offs
published: 2014-03-30T09:32:00Z
categories: Computer Science
tags: C++,intrinsics,Java,JNI,Optimization
---

Out of all Java codes convertible to C using the Java Native Interface, the following breed is the hardest to optimize: methods that are invoked very frequently and have low run time. More often than not the overhead entailed by JNI becomes significant enough that it offsets any gain in speed brought by native code, or worse, making the resulting program even slower. When optimizing a Java-based matrix multiplication program, I encountered a lot of such methods. Most of them are in the form of nested loops responsible of manipulating matrices on the order of 100 elements. Such trivial methods are generally not considered during optimization, but this time the sheer number of invocations have placed them at the top of the hot spot list. 

![Lots of invocations amplifies the JNI overhead](https://static.thinkingandcomputing.com/2014/03/hotspot.png)
Death by the numbers

Without proper optimization, the JNI-ed version actually takes more time than the Java implementation, due to various overhead. 

## Doing away with JNI altogether?

There exists a _de-jure_ solution: implement custom Java intrinsic functions. Many Java functions, mainly Math.* and Unsafe.*, already have their intrinsic counterparts built-in. When a piece of code calls one of such methods frequent enough, the JVM will directly inline the assembly from the intrinsic into the function call, effectively removing all call overhead while providing a fast implementation. While the built-in intrinsic functions are limited, it is possible to add your own intrinsics by modifying and recompiling the JVM. As stated in [this slide](http://www.slideshare.net/RednaxelaFX/green-teajug-hotspotintrinsics02232013 "Intrinsic Methods in HotSpot VM"), the Taobao JDK team implemented CRC32C intrinsics, which resulted in a more than 10x speed-up in CRC32 evaluation. 

Though sounds attractive, it is very hard to do in reality. After battling hours with scarce documentation and convoluted dynamic code generation process, I finally gave up trying to convert those matrix multiplication functions into intrinsics, especially when it involves two-dimensional arrays. 

So it seems that JNI is still the most feasible way to integrate native code into Java programs. But at times the overhead is just too significant. Fortunately, there are a number of measures one can take to minimize it. After experimenting with them, I would like to discuss the effectiveness of each method along with their limitations: 

## 1\. Use RegisterNatives

The RegisterNatives function binds a C++ method to a Java method name. The JVM does that automatically if the C++ method is exported and a Java native method with the corresponding name can be found, but RegisterNatives exposes this process, allowing non-exported functions to be used. There has been discussions stating that registering JNI functions manually is faster as it frees JVM from enumerating all exported functions in a library and identifying any matches. I wrote some example code to test this claim: 

<!--<pre lang="java" title="JNItest.java" class="crayon-selected">-->
```java
package test;

public class JNItest {
	static {
		System.loadLibrary("jnitest");
	}
	public static void main(String[] args) {
		long a = System.currentTimeMillis();
		for (int i=0; i<500000000; i++){
			callJNIMethod1();
		}
		long b = System.currentTimeMillis() - a;
		System.out.println("Time taken per call (RegisterNatives): "+(b/500d)+"ns");

		a = System.currentTimeMillis();
		for (int i=0; i<500000000; i++){
			callJNIMethod2();
		}
		b = System.currentTimeMillis() - a;
		System.out.println("Time taken per call: "+((double)b/500d)+"ns");
	}
	private native static void callJNIMethod1();
	private native static void callJNIMethod2();
}
```

And the corresponding C++ file:

<!--<pre lang="c++" title="jnitest.cpp">-->
```c++
#include <jni.h>

//method definition
void callJNIMethod(JNIEnv* env, jobject);
extern "C" {
JNIEXPORT void JNICALL Java_test_JNItest_callJNIMethod2(JNIEnv *env, jobject obj);
}

static JNINativeMethod s_methods[] = {
   {"callJNIMethod1", "()V", (void*)callJNIMethod}
};

jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
   JNIEnv *env = NULL;
   vm->GetEnv((void**)&env, JNI_VERSION_1_6);

   //class name is "JNItest"
   jclass cls = env->FindClass("Ltest/JNItest;");
   int len = sizeof(s_methods) / sizeof(s_methods[0]);
   env->RegisterNatives(cls, s_methods, len);
   return JNI_VERSION_1_6;
}

void callJNIMethod(JNIEnv* env, jobject)
{
   //does nothing...
}

JNIEXPORT void JNICALL Java_test_JNItest_callJNIMethod2(JNIEnv *env, jobject obj){
   //to be auto-discovered by JVM
}
```

After running the test program to compare the two, I discovered that using RegisterNatives actually cause JNI to be _slower_. But the difference is pretty much negligible. Therefore, RegisterNatives is not useful in reducing JNI overhead at all, contrary to some beliefs. The JNI call overhead is in fact quite small (less than 10ns on my environment), which means that a more insidious form of overhead lurks elsewhere, which brings us to:

## 2\. Caching Java objects

This measure is particularly helpful when a large number of arrays need to be passed to native code. Furthermore, JNI overhead actually increases linearly with the number of objects in an array passed to native code, even if the code is not using the array at all! To access an array from native code, JNI library functions Get<Type>ArrayElements need to be used. These functions typically copy the entire content of the array to a buffer location, and are undesirable. Functions such as GetPrimitiveArrayCritical, which instructs the JVM to make best effort to reveal the underlying pointer to the array, still add significant run time to the method, much larger than bare JNI call overhead alone. To mitigate this problem, it's possible to call this function to obtain pointers to arrays at the start of program execution, cache the pointer in a global variable, and subsequent calls would not need to call the function again to access the array. Easy to implement, this strategy resolves most JNI overhead problems.

But speed is not everything. Performance gains aside, this method has some serious limitations. According to Sun documentation, the Get/ReleasePrimitiveArrayCritical methods are supposed to be used like a critical section, meaning that pointers obtained should be briefly released instead of being held over a long period of time. It also suggests that doing otherwise may cause the VM to pause garbage collection, unless it supports pinning. A quick search indicated that most modern JVMs do not support pinning due to it being detrimental to performance of concurrent mark-sweep GC. This is further validated by the fact that on my testing environment (jdk 1.8.0), GC was disabled once GetPrimitiveArrayCritical was called and never released, causing the VM to eventually throw OutOfMemoryError. Hence the pointer needs to be periodically released to let GC catch a breath.

## 3\. Using ByteBuffer

The thrid method is a compromise from the second one. Java ByteBuffers allocate memory regions exempt from GC, hence won't be moved around or freed automatically. You can use ByteBuffer to create an area of the size equivalent to a float array, pass the pointer to the native code and perform operations on it. The ByteBuffer can be manipulated as an array of arbitrary primitive type by creating a view buffer. However, the downside is that existing code must be rewritten to use the view buffer to access the array.
