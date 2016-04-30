---
title: Speeding up gettext with memcache on Google App Engine, PHP
published: 2014-02-16T04:02:17Z
categories: Computer Science,Web
tags: GAE,gettext,memcache,php
---

<p>Google App Engine released experimental support for PHP lately. But it is still missing a critical feature central to building multi-language websites: internationalization support. PHP has an internationalization extension called gettext that allows developers to conveniently translate content and achieves <a href="http://en.wikipedia.org/wiki/Separation_of_presentation_and_content">content-layout separation</a>. Below is an example:</p>
<pre class="lang:python" title="message.po">#original text
msgid "gettext example"
#text after translation
msgstr "gettext 示例"
</pre>
<pre class="lang:php" title="test.php">
//tells gettext to look for simplified Chinese translation
putenv('LC_ALL=zh_CN');
setlocale(LC_ALL, "zh_CN");

//tells gettext to look for files named "messages.po"
$domain = "messages";
bindtextdomain($domain, "/");

//use the domain specified before
textdomain($domain);

echo _("gettext example");
//output should be "gettext 示例" instead
</pre>
<p>Translation is achieved by wrapping the text to be translated in a function called gettext(), commonly aliased as _(). This method is much more scalable than using Strings IDs, and is the preferred method of translation for large sites like Wordpress.</p>
<p>Unfortunately, the gettext native extension is not included in the GAE PHP runtime. In order to enable dynamic translation, one would have to resort to PHP implementations of the gettext library. <a href="http://mel.melaxis.com/devblog/2006/04/10/benchmarking-php-localization-is-gettext-fast-enough/">This</a> article showed that the PHP implementation is around 1.5x-2x slower than the extension. <!--more--></p>
<p>One of the reason is that PHP is rather stateless between requests: variables do not persist unless some serialization mechanism is used. Every time a request is made, the PHP implementation has to re-parse the .mo files required in translation. The gettext extension, on the other hand, not only caches the files between requests, but also runs in a native manner (the library is compiled into machine code, making it run much faster).</p>
<p>I wanted to deploy a multi-lingual application on GAE, but wanted to get as close to native performance as possible in translation, in absence of the native library. To achieve that, I took advantage of Google's memcache service, and used that to store the data parsed from .mo files between requests, hence reducing the time needed during translation.</p>
<p>I did a speed test using ApacheBench over 5000 requests, with concurrency value at 5. The language file used contains 10000 machine-generated strings. Below are the results on my development environment: nginx 1.4.4 + php-fpm.</p>
<div id="chart_div_gettext" style="width: 100%; max-width:500px; height: 400px; margin-left: auto; margin-right:auto; ">
<div style="text-align: center; margin-top: 100px; font-size: 25px; color: #bbb;">Loading chart data...</div>
</div>
<p>&nbsp;<br />The memcache-enabled version is still slower than the native library, but there is already a significant improvement of nearly 100% over the original PHP implementation.</p>
<p>The library can be found at Github <a href="http://github.com/tengyifei/php-gettext-memcached">here</a>.</p>
<p><script type="text/javascript">(function($) {$(document).on('ready pjax:success', function() {
	$.ajax({
    url: '//www.google.com/jsapi',
    dataType: 'script',
    cache: true,
    success: function() {
        google.load('visualization', '1', {
            'packages': ['corechart'],
            'callback': drawChart_gettext
        });
    }
});
      function drawChart_gettext() {
        var data = google.visualization.arrayToDataTable([
          ['', ''],
          ['Native gettext',  77],
          ['gettext-memcached',  233],
          ['PHP-gettext',  430]
        ]);var options = {
          title: 'Request latency (milliseconds) comparison',
		  legend: { position: "none" },
		  chartArea:{width:"90%",height:"90%"},
		  bar: {groupWidth: "40%"},
		  colors:['#91C41A']
        };var element=document.getElementById('chart_div_gettext');if (element!=null){var chart = new google.visualization.ColumnChart(element);
        chart.draw(data, options);}
      }
	  });})(jQuery);</script></p>


