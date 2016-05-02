---
title: How Javascript closures and functional expressions impact function equality
published: 2014-06-12T13:36:06Z
categories: Computer Science,Web
tags: closure
featured: true
---

Lately I made a mistake which I thought to be pretty prevalent among JavaScript beginners. More importantly, it revealed a subtle cross-browser JavaScript inconsistency regarding function declarations. I hope this article can clarify things a bit.

## The inception

To start with, it is pretty apparent that the code below will alert "false". From [this stackoverflow answer](http://stackoverflow.com/a/21680065) it is said that JavaScript checks for reference equality when encountering the "==" symbol. The two functions here, albeit does exactly the same thing, are different objects (i.e. residing at different memory locations), therefore the comparison result will be unequal.

```javascript
function foo() {
    a = 1;
};
function bar() {
    a = 1;
};
alert(foo==bar);
```

The error came when I was writing a callback manager. Several components will register a callback function to be executed. Because the website was using pjax, components will be repeatedly loaded and unloaded, so I needed to ensure the same callback function will not be registered twice. The approach I used can be simplified into the snippet below.

```javascript
var callback = [];
function addCallback(f){
    for (var i=0; i<callback.length; i++)
        if (callback[i] === f) return;
    callback[callback.length] = f;
}

//in other parts of the script
addCallback(function foo(){});
```

By examining the existing callbacks for duplicates, I thought I could prevent double registering, but this did not work as expected. When `addCallback(function foo(){})` was called two times, the function was added two times as well. This implies that the two functions are deemed as different ones, although they share the same name. This even works if addCallback was put in a loop and executed multiple times, which means that after running

```javascript
for(var i=0; i<5; i++){
    addCallback(function foo(){});
}
```

the value `callback.length` will be 5, even though each iteration is adding the same function! It is easy to understand why _foo_ and _bar_ are different functions in example one, but why is a function considered unequal to itself?

## JavaScript closures

It turns out that the above behavior is inevitable as a result of closures in JavaScript. This was initially a very foreign concept to me, but soon I began to appreciate its effectiveness. In short, closures are mechanisms to preserve a function's access to variables in its parent's scope, even after that scope has already terminated. In the example below, function _inner_ can access variable _x_ when called at line 8, at which point its enclosing function, _outer_, have long returned.

```javascript
function outer(x){
    return function inner(){
        return x+1;
    }
}

var func = outer(5);
func();    //correctly returns 6
```

One way to keep a reference to x is to keep a reference to the outer scope, which then has a reference to x. This is analogous to the way inner classes access fields in the parent class in Java i.e. by keeping an implicit reference to the parent instance.

When will the JavaScript engine create a closure? Obviously, one has to be created on reaching the definition of a function nested within another. In addition, [according to MDN](http://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Functions_and_function_scope), all function expressions form closures. The different cases can be summarized into the table below:

|                | Function declaration | Function expression |
|----------------|----------------------|---------------------|
| Global scope   | NO                   | YES                 |
| Function scope | YES                  | YES                 |

Here, loosely speaking, function declaration refers to statements of the form

```javascript
function name([params])
```

and function expressions are of one of the following syntax, or is part of an expression

```javascript
var variable = function [name]([param]){ ... };
(function [name]([param]){ ... })([param]);
```

 though the exact classification depends on a number of other factors as well. [*](#cbi)

 Therefore, in example two, each call to _addCallback_ comes with a function expression, which creates a closure capturing the current scope. Since there is no guarantee that the current scope will not terminate or change, each time the JavaScript engine encounters a function expression, it would have to allocate a new Function object housing a new reference to the parent scope. Thus the object passed into _addCallback_ will be different each time.

To allocate only one instance of that particular function, I only needed to change the function expression to a global scope function declaration:

```javascript
function foo(){}

for(var i=0; i<5; i++){
    addCallback(foo);
}
```

After five invocations of _addCallback_, callback.length equals one.

It's tempting to question the point in creating additional Function objects for function expressions in the global scope. After all, the global scope spans across the entirety of the JavaScript lifetime. There is no pressing reason to create closures for the global scope, hence ostensibly no need to make new objects to contain them, isn't it?

This might not be the case. Consider the following code snippet, it copies the loop counter into a field of the Function object.

```javascript
for(var i=0; i<5; i++){
    var foo = function (){
        foo.c = i;
        return foo;
    }
    addCallback(foo());
}
```

The n<sup>th</sup> element in callback array should have a member _c_ with value n-1\. If we were to optimize away the extra Function allocations and always return a shared copy of the anonymous function, all member _c_ in callback functions will be overwritten to 4 instead. This example may sound contrived, but it nonetheless demonstrates cases where eliminating seemingly redundant allocations can actually break things.

## <a name="cbi"></a>Cross-browser inconsistency

Firefox and Internet Explorer only treats functions that are not nested in control statements as function declarations, whereas Chrome thinks that any function with a name, as long as it is not part of an expression, is a function declaration. This inconspicuous difference can be visualized by running this script

```javascript
var callback = [];
function addCallback(f){
    for (var i=0; i<callback.length; i++)
        if (callback[i] === f) return;
    callback[callback.length] = f;
}

for(var i=0; i<5; i++){
    function foo(){}
        addCallback(foo);
}
alert(callback.length);
```

The alert string is 5 in IE and FF, but 1 in Chrome.

## A note on performance

Since closures and extra Function objects take up space and GC time, it is a bad practice to overuse function expressions in tight, intensive loops. Better convert them to function declarations, sacrificing a little bit on readability but may reap huge performance gains in some situations. When the micro-benchmark is run in Firefox 30, time taken was 1300ms when function foo was at global scope, and 330000ms when it was inside the for loop.

~~~~~~~~~~~~~~~~~~~~ {.javascript .numberLines startFrom="1"}
function bench(){
    var t0 = performance.now();
    var sum = 0;
    for (var i=0; i<1000000000; i++){
        function foo(x){
            return x;
        }
        sum += foo(i);
    }
    document.write(sum+"");
    var t1 = performance.now();
    document.write("Took " + (t1 - t0) + " milliseconds.");
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

_NB: This result in no way serves as an indication of the performance difference in real-life applications._
