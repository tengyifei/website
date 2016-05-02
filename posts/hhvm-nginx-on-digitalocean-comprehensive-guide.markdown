---
title: HHVM plus Nginx on DigitalOcean: a comprehensive guide
published: 2014-10-23T04:27:22Z
categories: Computer Science,Web
tags: HHVM,Nginx
---

After dithering between multiple PaaS options, I finally decided to settle down on a dedicated VPS for my blog. The motivation behind is three-fold: I get to enjoy fully static IP address which enables naked domain resolution (ditching WWW!); modifications to the local file system are preserved, a sine qua non for powerful caching plugins such as W3 Total Cache; last but not least, with SSDs and state-of-the-art Xeon processors, the relative performance is higher. 

Seamlessly migrating a Wordpress blog is not particularly straightforward. Platform differences between hosting partners, compounded by a plethora of plugins-cum-configurations necessitated nearly a day for thorough setup. In this post however, I will strip out the nitty-gritty details of blog migration and cover the essentials in setting up HHVM+Nginx on a DigitalOcean VPS.

## Setting up a droplet

If one were to consider "Ocean" as to comprising countless "droplets", the eponymous server building block is ostensibly a deliberate play on the company's title i.e. DitigalOcean. The virtual server has many Linux flavors. I chose Ubuntu 14.04 as it appeared to have the most recent software packages.

[![Droplet configuration](https://static.thinkingandcomputing.com/2014/10/droplet.png)](https://static.thinkingandcomputing.com/2014/10/droplet.png)

Droplet configuration

Be sure to check the "Private Networking" option, as it can be very helpful when expanding to more than one servers.

_A word on server sizes:_ at the time of writing, DigitalOcean does not support downsizing hard disk capacity, albeit it being a feature highly voted by the community. While this may seem like a trivial issue, the trouble comes when memory and CPU levels are bundled together with hard disk. Not being able to reduce disk quota implies to a large extent that you cannot downgrade the server at all. So do not over-provision your servers. After setting up a virtual server, you may SSH into it either from the password sent via e-mail or utilizing pre-uploaded public keys.

It is pertinent, before diving into configuring myriad of web services, to bolster the security of your virtual server. Two crucial measures apart from using strong passwords are apt firewall settings and depriving HHVM and Nginx processes of root privileges.

## IPTables

As its name suggests, IPTables is a Linux firewall that provides the first line of defense against external threats, by matching connections against a list of defined rules. Prior to altering the IPTables policies, we can use this command to see if there are any, which should not be present in the case of a stock Ubuntu intallation:

```
iptables -L -n
```

The following lines set the default action to accept for connections not matching any rules, and do a flush to obliterate any existing rules. It is crucial that the default actions are set to ACCEPT before the rules are flushed, or one may be locked out of the machine. The default ACCEPT policies are of course only transitory since no one wants to expose the server to all sorts of traffic.

~~~~ {.shell .numberLines startFrom="1"}
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The only vital incoming connections to the public network are SSH (to log in) and HTTP (to server web pages), thus we will solely enable them:

```
sudo iptables -A INPUT -p tcp --dport 22 -i eth0 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -i eth0 -j ACCEPT
```

Here eth0 refers to the public network interface on DigitalOcean VPS, while 22 and 80 represents the port number of SSH and HTTP respectively.

Next we permit loopback connections and public connections initiated by the server.

```
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -I OUTPUT -o eth0 -j ACCEPT
```

If you are hosting your database at another server, there should also be rules explicitly allowing connections to that server in the private network. Interface eth1 is the private ethernet interface in DigitalOcean.

```
sudo iptables -A OUTPUT -o eth1 -p tcp -d <db_server_ip> --dport 3306 -j ACCEPT
sudo iptables -A INPUT -i eth1 -p tcp -j ACCEPT
```

When finished with configuration, set default policy for all other connections to DROP:

```
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
```

Caveat: IPTables rules are by default not set to survive reboots. To retain your fastidiously written rules there is a convenient package called iptables-persistent. Install it and follow the guides to save the IPTables config.

```
apt-get install iptables-persistent
```

## Install Fail2Ban

Your virtual server is not a secluded island in the expansive Internet. If you are confident that you will only be accessing it from a few static IP addresses, you can whitelist those IPs in SSH service. For the vast majority, static IP may well be a luxury, and consequently the SSH service must be exposed to the Internet (unless you proxy SSH over a trusted server. This digresses into another topic). While the IP adress can be hidden from public, the Internet is replete with sharks lurking around, targeting VPS IP ranges using port scanners and brute-force cracking utilities. It is common to be greeted by your server with such distressing sentences:

```
Last failed login: Sun Oct 26 21:06:46 EDT 2014 from 88.135.1.99 on ssh:notty
There were 13026 failed login attempts since the last successful login.
```

Tracing the IP leads to some obscure location in Russia and [a litany of offenses](http://www.abuseipdb.com/report-history/88.135.1.99).

A stopgap measure is to install Fail2Ban, a program that monitors rejected login attempts and bans them temporarily using the aforementioned IPTable.

```
apt-get install fail2ban
```

The default configuration blocks any address temporarily for 10 minutes after 3 unsuccessful logins.

## Relegating HHVM and Nginx to an unprivileged user

Considerable number of attacks uses web servers as a springboard to launch other malicious processes. By limiting access to the system we effectively curbs the degree of damage they can do. At this stage we only create a new user using the adduser command, leaving details on how to handle the permissions later.

```
# Creates a new user named "webuser".
# You will be prompted to enter password and sundry information.
adduser webuser
```

Now, with certain level of security in check, we may move on to installing software packages. First up, HHVM.

## HHVM on Ubuntu

HHVM binaries are actively maintained. To get them we merely have to import the HHVM repository and install it from there:

```
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/
echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list

sudo apt-get update
sudo apt-get install hhvm
hhvm --version
```

If everything functions as intended, the last command should output the HHVM version information, which for me was 3.3.0.

## Installing Nginx on Ubuntu

The stock Nginx version is a bit obsolete; 1.4.7 was an old branch with latest security fixes, but fewer features. The Nginx team maintains a repository with latest versions. Adding it and installing Nginx is simple:

```
sudo add-apt-repository ppa:nginx/development
sudo apt-get install nginx
```

## Compiling Nginx on Ubuntu (Deprecated)

_This section describes how to compile Nginx on your own, which is not the recommended way of installing Nginx but may provide more flexibility._

To obtain the most recent source and compile it, execute the following commands, substituting 1.7.6 with whichever version desired.

```
apt-get install libpcre3-dev build-essential libssl-dev dpkg-dev build-essential zlib1g-dev libpcre3 libpcre3-dev unzip libxslt-dev libgeoip-dev geoip-database
NGINX_VERSION=1.7.6
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}/

./configure \
--with-http_ssl_module \
--with-pcre-jit \
--with-ipv6 \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_geoip_module \
--with-http_gzip_static_module \
--with-http_spdy_module \
--with-http_sub_module \
--with-http_xslt_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio

CFLAGS="-O3" CXXFLAGS="-O3" make
make install
cp objs/nginx /usr/local/sbin/
```

Some lines worth mentioning: I had to manually specify the optimization levels when invoking make, otherwise the compiler will use the default optimization level, resulting in an exceedingly large binary with abysmal performance. Furthermore, you can tune the list of modules compiled into the final binary, though the provided bunch should suffice under most daily usage.

## Setting up Supervisord

At the moment, although circumstances have been improving, HHVM is prone to sporadic crashes. To minimize their impact on server uptime, I used a monitoring daemon called Supervisord. It spawns stipulated executables at start up and attempts to restart them should any process exit unexpectedly. To install Superviosrd, a program named easy_install is required, which belongs to the python-setuptools package:

```
apt-get install python-setuptools
easy_install supervisor
```

The default config file for Supervisord is located at `/etc/supervisord.conf.` First we may turn off the built in administration server by commenting out [unix_http_server] and [inet_http_server] headers, following which are the settings for each process to be managed. Below is a sample configuration for HHVM. Nginx, on the other hand, is relatively much less susceptible to crashes and can be installed as a service.

```
[program:hhvm]
command=hhvm -m server -vServer.Type=fastcgi
    -vServer.FileSocket=/usr/local/nginx/hhvm.sock
    -vEval.EnableZendCompat=true
    -vRepo.Central.Path=/usr/local/nginx/.hhvm.hhbc
    -vLog.UseLogFile=true -vLog.File=/home/webusr/hhvm.log
    -c /etc/hhvm/php.ini
directory=/usr/local/nginx/html
autostart=true            ; start at supervisord start (default: true)
user=webuser               ; setuid to this UNIX account to run the program
redirect_stderr=true      ; redirect proc stderr to stdout (default false)
stdout_logfile=~/hhvm_stdout.log   ; stdout log path, NONE for none;
```

The line "user=webuser" instructs Supervisord to execute HHVM from the unprivileged account.

Lastly, before firing up Nginx, we need to edit its configuration file, found at /usr/local/nginx/conf/nginx.conf, to let it run the worker processes under webuser as well. Inserting this at the beginning:

```user webuser;```

If you intend to run sites that modifies the local file system e.g. installing plugins in Wordpress, the files and directories involved need to be "chown"ed to webuser. The command to process the entire Nginx web root is provided below:

```chown -R webuser: /usr/local/nginx/html```
