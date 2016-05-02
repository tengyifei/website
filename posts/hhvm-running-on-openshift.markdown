---
title: Get HHVM running on OpenShift
published: 2014-06-26T16:07:01Z
categories: Computer Science,Web
tags: HHVM,OpenShift,PaaS
featured: true
---

The past four days had been particularly fruitful to me. In a nutshell, I've managed to compile HHVM along with a couple of extensions for RHEL 6, and packaged it with Nginx to build a web cartridge. **TL; DR** For those who just want the link to the cartridge repository, here it is: [http://github.com/tengyifei/openshift-cartridge-nginx-hhvm](http://github.com/tengyifei/openshift-cartridge-nginx-hhvm). Alternatively, you can add the cartridge via reflector url: `http://cartreflect-claytondev.rhcloud.com/github/tengyifei/openshift-cartridge-nginx-hhvm`. Otherwise, feel free to read on and I hope this article can serve as a valuable guide to developing cartridges for OpenShift.

## OpenShift v.s. Heroku

I was comparing PaaS hosting options, and chose OpenShift over Heroku for two reasons: the capability to run the database in a separated node, and the fact that single gear/dyno performance is much higher in OpenShift under the free tier. But getting my PHP app to run on OpenShift turned out to be an arduous task. There are community cartridges available offering PHP FastCGI with Nginx, and after some tinkering, I got one running with some basic PHP documents, but then came the obstacle: my app required the Redis and APCu extensions, both of which are absent in the stock PHP installation. I tried to find somewhere in the cartridge where I could drop in some custom in vain. As I rummaged in the repository, the situation turned more bizarre: the PHP binary seemed to have came from nowhere. There were no signs of downloading it from S3 cloud, a prevailing practice in Heroku buildpacks, nor was it stashed away at some nondescript corners of the repository. It was only after reading lots of online tutorials and SSH-ing into the gears did I realize the obvious: PHP was installed by default on the Red Hat Enterprise Linux systems that underpins OpenShift. Sure, as an OS destined for the commercial market, it was perfectly reasonable for RHEL to incorporate common software such as Apache or PHP to facilitate sysadmins in configuring servers. But like all pre-packaged software, the downside is the loss of flexibility. This is compounded by the limited user permission on gears. I couldn't change any of the configurations or add or remove extensions, because they were all residing in write-protected `/var` directories! (Though while typing this I realized that a use of the `-c` switch would have caused PHP to read a different config file, thereby eschewing all the tedious process below.)

## HHVM on OpenShift

For one reason or another, I decided to use HHVM in favor of the built-in PHP. I couldn't merely run "sudo yum install hhvm" due to the lack of necessary permission, so I sought for an HHVM binary compatible with RHEL to upload manually. It appeared that [the compiled binary for CentOS](http://nareshv.blogspot.com/2013/05/install-hhvm-hiphop-php-on-centos-64-64.html) would suffice, since CentOS was virtually binary compatible with RHEL. Without any hesitation, I extracted hhvm from the rpm package and ran it on OpenShift.

![HHVM dependency error](https://static.thinkingandcomputing.com/2014/06/hhvm_err.png)

...And it failed to start. Unaware of the significant number of third-party libraries HHVM required, I conveniently thought that downloading the missing library would solve the problem. But it didn't. One after one, more dependency errors surfaced. Some libraries depended on many other extraneous libraries, causing the dependency chain to quickly burgeon into a scale barely tractable by hand. Occasionally, one library would require a different version of another one. And after I replace the offending file, more errors ensued, since in fact that file was required by some other libraries as well. The clock was ticking late into the night. Imagine how disheartening it was to me, trying to untangle the Linux counterpart of "DLL hell" from a machine thousands of miles away.

Turned out that unlike Microsoft, binary-level backward compatibility was never a concern, much less an aim for Linux. If a compiled library was not meant for exactly your system flavor and version, there was absolutely no guarantee whether it will work or wreck havoc. I learnt this the hard way.

## Vagrant up!

The next morning I had an idea. If I could get super-user access to a machine with identical configuration as those in OpenShift, it would be much easier to resolve all the dependency problem. The bottom line is that I could compile HHVM and all associated libraries in situ and transfer the files to OpenShift. The tool of the trade is Vagrant, a program that automatically sets-up a virtualized environment. Using the [vagrant configuration provided by OpenShift](http://github.com/openshift/vagrant-openshift), I installed RHEL in a virtual machine. Then I installed HHVM from an unofficial repository. There were some hiccups along the way, but they were soon overcome. One peculiar error was the following:

```
hhvm: symbol lookup error: hhvm: undefined symbol: _ZN61FLAG__namespace_do_not_use_directly_use_DECLARE_int32_instead7FLAGS_vE
```

 This was due to an incompatible version of the glog library. By removing the default glog 0.3.3 and installing 0.3.2, this problem was solved too.

## Other things worth mentioning

*   To turn HHVM on and off, I had to track its process id. HHVM can be instructed to store its pid at a specified location via the "PidFile" option. In OpenShift cartridge this location was set to the app data directory, since it is a persistent directory to which the user have write access.
*   The HHVM central repo location also needs to be changed, since the user does not have permission to write to the default repo location /var/run/hhvm.hhbc.
*   For some unclear reason, HHVM could not bind to a TCP address in FastCGI mode. So I switched to Unix file sockets instead. They were commonly regarded faster anyways.

Initially I could not get HHVM to read the configuration by any means. It loaded the file and nothing happened. After many hours of debugging I discovered the culprit was line ending characters. On Windows, git would automatically convert CR LF to the Unix-style LF when pushing, but this was not the case in Linux, and the CR LF line endings somehow caused HHVM to stop parsing the file.
