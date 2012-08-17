---
layout: post
title: Installing and running nginx, jekyll and your blog from scratch
date: 2012-08-16 19:56:00 -05:00
categories:
  -- nginx
  -- jekyll
  -- centos
---

This blog is a bunch of HTML created by [jekyll](https://github.com/mojombo/jekyll). I'm hosting
it on a VM, and this post is the sequence of steps that I used to setup the blog on my VM from scratch.
The instructions that follow were executed on a CentOS 6 VM.

## Create a user and setup ssh

With a new VM you'll typically be given root access, but security 101 dictates that you avoid running
commands as the root user as much as possible. Therefore the first thing you'll want to do is to create a
user, in this case `bloguser`:

    shell$ useradd bloguser

Next, change the password for the user:

    shell$ passwd bloguser

Now you'll want to create a SSH public/private key set for your user.
It's recommended that you do this on your
own machine, not your VM, since you don't want your private key out there if it can be avoided.

    shell$ ssh-keygen -t rsa

This will generate the following files on your local host:

    .ssh/id_rsa
    .ssh/id_rsa.pub

Once these files are generated, create the `.ssh` directory on your VM (these steps assume you're logged-in as root):

    shell$ su - bloguser
    shell$ mkdir .ssh

Create `.ssh/authorized_keys` on your VM, and copy the contents of `.ssh/id_rsa.pub` from your local
host:

    shell$ vi .ssh/authorized_keys

Setup the permissions on the directory and file.

    shell$ chmod 700 .ssh
    shell$ chmod 600 .ssh/authorized_keys

Test out your ssh setup, by ssh-ing from your local host to your VM as the `bloguser` user:

    shell$ ssh bloguser@<vm-host>

As root, allow the `bloguser` user to perform commands as root (if the `/etc/sudoers` file doesn't
exist, then you will need to install `sudo` with the `yum install sudo` command).

    shell$ vi /etc/sudoers

Add the following line:

    %bloguser       ALL=(ALL)       ALL


## Setup some basic security

Next up is tighten-up the SSH configuration.

    shell$ sudo vi /etc/ssh/sshd_config

Inside this file you will do three things:

1. Change the port from 22 to some other number (such as 52846 in the example below).
2. Disable password authentication, so that a private key must be used to login to the server.
3. Block the root user from ssh access to your host.

The file therefore needs to contain the following lines (make sure all other entries
with these names are commented-out).

    Port 52846
    PasswordAuthentication no
    PermitRootLogin no

Restart the ssh daemon to pick up the changes you just made.

    shell$ sudo /sbin/service sshd restart


The next step is to setup a firewall to restrict incoming traffic to just ssh and HTTP.
To do this create a file called `vm-iptables.sh` with the following content. You'll be
executing the following commands as root.

<pre><code>
#!/bin/bash

# Flush all current rules from iptables
iptables -F

# Allow SSH and HTTP connections
iptables -A INPUT -p tcp --dport 52846 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Drop traffic on all other inbound ports
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Allow all outbound traffic
iptables -P OUTPUT ACCEPT

# Accept any connection on the local port
iptables -A INPUT -i lo -j ACCEPT

# Accept packets belonging to established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Save the iptables
/sbin/service iptables save

# List
iptables -L -v
</code></pre>

After you've created the file, make it an executable and execute it to save your rules.

<pre><code>
shell$ chmod +x ./vm-iptables.sh
shell$ sudo ./vm-iptables.sh
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
Chain INPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    2   104 ACCEPT     tcp  --  any    any     anywhere             anywhere            tcp dpt:ssh
    0     0 ACCEPT     tcp  --  any    any     anywhere             anywhere            tcp dpt:http
    0     0 ACCEPT     all  --  lo     any     anywhere             anywhere
    0     0 ACCEPT     all  --  any    any     anywhere             anywhere            state RELATED,ESTABLISHED

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 2 packets, 264 bytes)
 pkts bytes target     prot opt in     out     source               destination
</code></pre>

The output shows your new iptables configuration which reflects the rules we saved in `myvm-iptables.sh`.

## Install and start nginx

Add the EPEL yum repository into your configuration:

    shell$ sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-7.noarch.rpm

Install nginx using yum:

    shell$ sudo yum install nginx

Setup nginx so that it auto-starts at system start time:

    shell$ sudo chkconfig nginx on

Start nginx:

    shell$ sudo /sbin/service nginx start

You can test that nginx is up and running by pointing your browser at your VM IP address - you
should see a page confirming that all is good.

![nginx welcome screen](/images/nginx-welcome.png)

## Install jekyll



## Create a crontab entry

