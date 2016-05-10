---
title: Persisting Java objects across JNI calls using global references
published: 2014-04-30T08:50:17Z
categories: Computer Science
tags: Java,JNI
featured: true
---

In a previous post I mentioned that [caching array pointers can significantly reduce JNI overhead](./eliminating-jni-overhead.html "Eliminating JNI overhead: tricks and trade-offs"). But in order to maintain the validity of the cached pointers, one has to go against the docs: obtaining the pointer using GetPrimitiveArrayCritical but only releasing it sporadically. This entails that the critical section created between Get and ReleasePrimitiveArray has to span across multiple JNI calls. <!--more-->Initially I thought it would be a trivial task since I could just save the array object into a global variable, and after several JNI calls, I can still access the same object, like this:

```c++
jobjectArray array;
void *ptr;

void GetPointerToArray(JNIEnv *env, jobjectArray arr){
    //store into global static storage
    array = arr;
    ptr = env->GetPrimitiveArrayCritical(arr, 0);
    //Do something with the data...
}
```

And after a few JNI calls,

```c++
void ReleasePointerToArray(JNIEnv *env){
    env->ReleasePrimitiveArrayCritical(array, ptr, 0);
}
```

However, things turned out to be more complicated than they seem. Once I release the array, the VM crashes with the following error:

```
#
# A fatal error has been detected by the Java Runtime Environment:
#
#  EXCEPTION_ACCESS_VIOLATION (0xc0000005) at pc=0x6e5b8c3e, pid=8148, tid=7924
#
# JRE version: Java(TM) SE Runtime Environment (8.0-b127) (build 1.8.0-b127)
# Java VM: Java HotSpot(TM) Server VM (25.0-b69 mixed mode windows-x86 )
# Problematic frame:
# V  [jvm.dll+0xd8c3e]
#

---------------  T H R E A D  ---------------

Current thread (0x01a0c400):  JavaThread "main" [_thread_in_vm, id=7924, stack(0x01a80000,0x01ad0000)]

siginfo: ExceptionCode=0xc0000005, reading address 0x5d03bd0d
```

Not only does the JVM fatals on this method call, when I use GetArrayLength to check the length of the array, the result returned is often some nonsensically huge number.

Probably the objects passed to JNI functions are only pointers to some stack variables allocated during in preparation for that particular JNI call. After the method returns, the variables will be automatically freed and its contents gradually overwritten, causing the pointer to become invalid.

After examining the [relevant Java docs](http://publib.boulder.ibm.com/infocenter/javasdk/v6r0/index.jsp?topic=%2Fcom.ibm.java.doc.diagnostics.60%2Fdiag%2Funderstanding%2Fjni_refs.html), it became clear that these objects passed as arguments are called local references, meaning that they are only valid within the scope of their creating stack frame. To keep a local reference valid even after its method returns, one could promote it to a global reference using NewWeakGlobalRef function. Therefore, the code before can be modified into:

```c++
jobjectArray array;
void *ptr;

void GetPointerToArray(JNIEnv *env, jobjectArray arr){
    array = arr;
    ptr = env->GetPrimitiveArrayCritical(arr, 0);
    //promote the reference to a global reference
    env->NewWeakGlobalRef(arr);
    //Do something with the data...
}

void ReleasePointerToArray(JNIEnv *env){
    env->ReleasePrimitiveArrayCritical(array, ptr, 0);
    env->DeleteWeakGlobalRef(array);
}
```

Please note that the object returned by NewWeakGlobalRef is still subject to garbage collection, hence the pointer may become invalid before ReleasePointerToArray is called should there be no additional reference (including any in Java) to that particular object, again causing an access violation error. But in my case, since calling GetPrimitiveArrayCritical effectively disables GC anyways, there is no worry about the pointer becoming invalid.
