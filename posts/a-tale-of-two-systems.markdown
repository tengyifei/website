---
title: A tale of two systems
published: 2014-02-03T13:53:09Z
categories: Computer Science,Web
tags: GAE,Linux,Windows
---

Today I noticed in my App Engine console a large number of HTTP 4xx errors. Strangely though, they all revolved around a single image file, mrq_2.png:

[![4xx_error](//static.thinkingandcomputing.com/2014/02/4xx_error.png)](//static.thinkingandcomputing.com/2014/02/4xx_error.png)

"That's weird." I thought. There is an exact same file with the same name located in the website on my local filesystem:

[![files](//static.thinkingandcomputing.com/2014/02/files.png)](//static.thinkingandcomputing.com/2014/02/files.png)

Even stranger, when I tested the website on my local nginx server, everything worked like a charm. Not a single File Not Found error emerged.

And then it struck me: case-sensitivity! Somehow two image files had a capitalized file extension "PNG" instead of "png". On Windows, the file system is case-insensitive, so when there is a request searching for "mrq_2.png" the system will incorrectly return "mrq_2.PNG" instead, producing superficially correct results. But when the website is uploaded to Google servers, which probably runs a flavor of linux, a case-sensitive system, "mrq_2.png" cannot be found.

When I tried renaming the capitalized file extension back to "png", Windows _duly ignored_ that operation, leaving me with "PNG" again. I had to rename it to something else like "abc" then change it to "png".

After the renaming process and redeploying the website, the error was gone.

Another incentive for me to migrate to linux...
