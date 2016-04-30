---
title: GWT-PHP RPC Example
published: 2014-05-11T06:15:41Z
categories: 
tags: 
---

<p>This project lets you call PHP functions using GWT's built-in RPC mechanism. </p>
<h2>Demo</h2>
<p><iframe id="gwt-demo-frame" width="600px" height="350px" seamless src="/wp-content/gwtphp-demo.html"></iframe></p>
<p>Server-side code:</p>
<pre lang="php">&lt;?php
class GreetingServiceImpl {

    public function greetServer($input){
        $userAgent = $_SERVER['HTTP_USER_AGENT'];

        $input = $this-&gt;escapeHtml($input);
        $userAgent = $this-&gt;escapeHtml($userAgent);

        return "Hello, " . $input . "!&lt;br&gt;&lt;br&gt;I am running " . "PHP " . phpversion()
        . ".&lt;br&gt;&lt;br&gt;It looks like you are using:&lt;br&gt;" . $userAgent;
    }

    private function escapeHtml($html){
        return htmlspecialchars($html);
    }

    public function getSumLong($a, $b){
        return $a-&gt;longValue() + $b-&gt;longValue();
    }

    public function doError(){
        throw new IllegalArgumentException("Java system exception");
    }
}
</pre>
<p>Project on github: <a href="http://github.com/tengyifei/gwtphp" target="_blank">http://github.com/tengyifei/gwtphp</a></p>

