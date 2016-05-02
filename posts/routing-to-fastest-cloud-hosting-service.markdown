---
title: PaaS: Routing to nearest host for minimum latency
published: 2014-03-13T14:34:40Z
categories: Computer Science,Web
tags: Baidu App Engine,DNS,dnspod,GAE,heroku,PaaS
---

Many people today are using PaaS (Platform-as-a-Service) nowadays to build their websites. Most service providers typically cluster their servers in a small region, and route all traffic from the entire Internet to that one place. This is fine if the servers are pretty close to their targeted audience, but page loading performance would be abysmal if the server is located in the U.S. and trying to reach users in, say, China. Since network latency has [significant impact](http://googleresearch.blogspot.com/2009/06/speed-matters.html "Speed Matters") on user experience, it is vital to keep servers in the vicinity of the users, but the spatially-restricted nature of PaaS impedes one from reaching out to a global audience. 

And I was confronted with the exact same circumstances while building a website for an export-oriented Chinese company. They needed to appeal to their domestic costumers as well, hence the website must be fast both within China and around the world (their other targeted markets reside in Europe, South-east Asia and North America). Furthermore, their pages were mostly dynamic content, which coupled with intervention from GFW made most CDN acceleration unfeasible. I needed to seek a cost-effective solution to spread the load across geographically-diverse servers.

Fortunately, the content of their website need not be closely synchronized across geographic boundaries. Therefore it will be possible to host the content on multiple discrete PaaS services, each dedicating to serving users from its neighborhoods. After thorough benchmarks using speed-testing services, I chose the following three PaaS service providers: Heroku, Google App Engine (GAE) and Baidu App Engine (BAE). 

Heroku is one of the few PaaS that provides the option to deploy the application in Europe, thus taking care of users there and in Middle-East. It is also more extendable under free tier than its counterpart, Openshift. BAE, on the other hand, excels at serving Chinese users with its sophisticated data-centers spread all over China. The rest of the requests will be served by GAE, which demonstrates generally moderate latency globally, but is slower than Heroku in Europe and fumbles in China.

[![Example diagram illustrating the traffic-splitting effect reducing latency](https://static.thinkingandcomputing.com/2014/03/dns_map.png)](https://static.thinkingandcomputing.com/2014/03/dns_map.png)
<tnc-caption>Example diagram illustrating the traffic-splitting effect reducing latency</tnc-caption>

The solution outlined above looks attractive, but may be troublesome to implement in practice. There needs to some kind of a load-balancer that intercepts all traffic, checks the user's geographical location using IP address and redirects the connection to one of the aforementioned services. Luckily, a similar effect can be achieved without the complications of this set-up. That is, DNS-based traffic management.

Generally, when an application deployed need to be binded to a top-level domain, CNAME mapping is the preferred method. The domain manager redirects all requests to the naked domain _example.com _to _www.example.com_, and mark _www_ as a canonical name for the application's default secondary-level domain. When the user resolves for the domain name, the request would eventually be guided to the application's original domain, although the URL would still appear as _www.example.com_. 

It is then possible to configure the DNS service to give different results for the CNAME look-up for users from different geographical locations, though not all DNS services support this. _DNS Made Easy_ provides the global traffic director function which partially satisfies my requirements by enabling different CNAME records for four regions (US East, US West, Europe, Asia). _DNSPOD_ provides even more fine-grained controls, allowing configurations on a per-country basis for free. In my case, I chose _DNSPOD_ as the DNS resolving service since it is free of charge. This can be accomplished by changing the name servers at the domain registrar to those from _DNSPOD_.

After properly configuring the DNS records, a look-up test shows the following: 

[![Different regions were directed to different servers for the same CNAME.](https://static.thinkingandcomputing.com/2014/03/dns.png)](https://static.thinkingandcomputing.com/2014/03/dns.png)
<tnc-caption>Different regions were directed to different servers for the same CNAME.</tnc-caption>

And that's it! Users will now automatically visit the nearest server. But the downside of multiple PaaS is that data will not be synchronized across servers, and some form of custom syncing logic has to be implemented.
