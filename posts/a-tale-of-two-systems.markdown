---
title: A tale of two systems
published: 2014-02-03T13:53:09Z
categories: Computer Science,Web
tags: GAE,Linux,Windows
---

<p>Today I noticed in my App Engine console a large number of HTTP 4xx errors. Strangely though, they all revolved around a single image file, mrq_2.png:</p>
<p><a href="//static.thinkingandcomputing.com/2014/02/4xx_error.png"><img class="alignnone size-full wp-image-26" alt="4xx_error" src="//static.thinkingandcomputing.com/2014/02/4xx_error.png" width="401" height="98" /></a></p>
<p>"That's weird." I thought. There is an exact same file with the same name located in the website on my local filesystem:</p>
<p><a href="//static.thinkingandcomputing.com/2014/02/files.png"><img class="alignnone size-full wp-image-39" alt="files" src="//static.thinkingandcomputing.com/2014/02/files.png" width="150" height="150" /></a></p>
<p>Even stranger, when I tested the website on my local nginx server, everything worked like a charm. Not a single File Not Found error emerged.<!--more--></p>
<p>And then it struck me: case-sensitivity! Somehow two image files had a capitalized file extension "PNG" instead of "png". On Windows, the file system is case-insensitive, so when there is a request searching for "mrq_2.png" the system will incorrectly return "mrq_2.PNG" instead, producing superficially correct results. But when the website is uploaded to Google servers, which probably runs a flavor of linux, a case-sensitive system, "mrq_2.png" cannot be found.</p>
<p>When I tried renaming the capitalized file extension back to "png", Windows <em>duly ignored</em> that operation, leaving me with "PNG" again. I had to rename it to something else like "abc" then change it to "png".</p>
<p>After the renaming process and redeploying the website, the error was gone.</p>
<p>Another incentive for me to migrate to linux...</p>


