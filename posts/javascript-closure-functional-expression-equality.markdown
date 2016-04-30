---
title: How Javascript closures and functional expressions impact function equality
published: 2014-06-12T13:36:06Z
categories: Computer Science,Web
tags: closure
---

<p>Lately I made a mistake which I thought to be pretty prevalent among JavaScript beginners. More importantly, it revealed a subtle cross-browser JavaScript inconsistency regarding function declarations. I hope this article can clarify things a bit.</p>
<h2>The inception</h2>
<p>To start with, it is pretty apparent that the code below will alert "false". From <a href="http://stackoverflow.com/a/21680065" target="_blank">this stackoverflow answer</a> it is said that JavaScript checks for reference equality when encountering the "==" symbol. The two functions here, albeit does exactly the same thing, are different objects (i.e. residing at different memory locations), therefore the comparison result will be unequal.</p>
<pre class="lang:js decode:true" title="Example one">function foo() {
    a = 1;
};
function bar() {
    a = 1;
};
alert(foo==bar);</pre>
<p>The error came when I was writing a callback manager. Several components will register a callback function to be executed. Because the website was using pjax, components will be repeatedly loaded and unloaded, so I needed to ensure the same callback function will not be registered twice. The approach I used can be simplified into the snippet below.</p>
<pre class="lang:js decode:true" title="Example two">var callback = [];
function addCallback(f){
    for (var i=0; i<callback.length; i++)
        if (callback[i] === f) return;
    callback[callback.length] = f;
}

//in other parts of the script
addCallback(function foo(){});</pre>
<p>By examining the existing callbacks for duplicates, I thought I could prevent double registering, but this did not work as expected. When <span class="inlinecode">addCallback(function foo(){})</span> was called two times, the function was added two times as well. This implies that the two functions are deemed as different ones, although they share the same name. This even works if addCallback was put in a loop and executed multiple times, which means that after running</p>
<pre class="lang:js decode:true" toolbar="false">for(var i=0; i<5; i++){
    addCallback(function foo(){});
}</pre>
<p>the value <span class="inlinecode">callback.length</span> will be 5, even though each iteration is adding the same function! It is easy to understand why <em>foo</em> and <em>bar</em> are different functions in example one, but why is a function considered unequal to itself?<!--more--></p>
<h2>JavaScript closures</h2>
<p>It turns out that the above behavior is inevitable as a result of closures in JavaScript. This was initially a very foreign concept to me, but soon I began to appreciate its effectiveness. In short, closures are mechanisms to preserve a function's access to variables in its parent's scope, even after that scope has already terminated. In the example below, function <em>inner</em> can access variable <em>x</em> when called at line 8, at which point its enclosing function, <em>outer</em>, have long returned.</p>
<pre class="lang:js decode:true" toolbar="false">function outer(x){
    return function inner(){
        return x+1;
    }
}

var func = outer(5);
func();    //correctly returns 6</pre>
<p>One way to keep a reference to x is to keep a reference to the outer scope, which then has a reference to x. This is analogous to the way inner classes access fields in the parent class in Java i.e. by keeping an implicit reference to the parent instance.</p>
<p>When will the JavaScript engine create a closure? Obviously, one has to be created on reaching the definition of a function nested within another. In addition, <a href="http://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Functions_and_function_scope" target="_blank">according to MDN</a>, all function expressions form closures. The different cases can be summarized into the table below:</p>
<p>
[table th="0"]</p>
<p> , Function declaration, Function expression<br />
Global scope, NO, YES<br />
Function scope, YES, YES<br />
[/table]
</p>
<p>Here, loosely speaking, function declaration refers to statements of the form</p>
<pre class="lang:js decode:true" toolbar="false">function name([params])</pre>
<p>and function expressions are of one of the following syntax, or is part of an expression</p>
<pre class="lang:js decode:true" toolbar="false">var variable = function [name]([param]){ ... };
(function [name]([param]){ ... })([param]);</pre>
<p> though the exact classification depends on a number of other factors as well. <a href="#cbi">*</a></p>
<p> Therefore, in example two, each call to <em>addCallback</em> comes with a function expression, which creates a closure capturing the current scope. Since there is no guarantee that the current scope will not terminate or change, each time the JavaScript engine encounters a function expression, it would have to allocate a new Function object housing a new reference to the parent scope. Thus the object passed into <em>addCallback</em> will be different each time.</p>
<p>To allocate only one instance of that particular function, I only needed to change the function expression to a global scope function declaration:</p>
<pre class="lang:js decode:true" toolbar="false">function foo(){}

for(var i=0; i<5; i++){
    addCallback(foo);
}</pre>
<p> After five invocations of <em>addCallback</em>, callback.length equals one.</p>
<p>It's tempting to question the point in creating additional Function objects for function expressions in the global scope. After all, the global scope spans across the entirety of the JavaScript lifetime. There is no pressing reason to create closures for the global scope, hence ostensibly no need to make new objects to contain them, isn't it?</p>
<p>This might not be the case. Consider the following code snippet, it copies the loop counter into a field of the Function object.</p>
<pre class="lang:js decode:true" toolbar="false">for(var i=0; i<5; i++){
    var foo = function (){
        foo.c = i;
        return foo;
    }
    addCallback(foo());
}</pre>
<p>The n<sup>th</sup> element in callback array should have a member <em>c</em> with value n-1. If we were to optimize away the extra Function allocations and always return a shared copy of the anonymous function, all member <em>c</em> in callback functions will be overwritten to 4 instead. This example may sound contrived, but it nonetheless demonstrates cases where eliminating seemingly redundant allocations can actually break things.</p>
<h2><a name="cbi"></a>Cross-browser inconsistency</h2>
<p>Firefox and Internet Explorer only treats functions that are not nested in control statements as function declarations, whereas Chrome thinks that any function with a name, as long as it is not part of an expression, is a function declaration. This inconspicuous difference can be visualized by running this script</p>
<pre class="lang:js decode:true" toolbar="false">
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
</pre>
<p>The alert string is 5 in IE and FF, but 1 in Chrome.</p>
<h2>A note on performance</h2>
<p>Since closures and extra Function objects take up space and GC time, it is a bad practice to overuse function expressions in tight, intensive loops. Better convert them to function declarations, sacrificing a little bit on readability but may reap huge performance gains in some situations. When the micro-benchmark is run in Firefox 30, time taken was 1300ms when function foo was at global scope, and 330000ms when it was inside the for loop.</p>
<pre class="lang:js decode:true">
function bench(){
    var t0 = performance.now();
    var sum = 0;
    for (var i=0; i<1000000000; i++){
        function foo(x){
            return x;
        }
        sum += foo(i);
    }
    document.write(sum+"<br>");
    var t1 = performance.now();
    document.write("Took " + (t1 - t0) + " milliseconds.<br><br>");
}
</pre>
<p><em>NB: This result in no way serves as an indication of the performance difference in real-life applications.</em></p>


