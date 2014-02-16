---
layout: post
title: Using Oozie 4.4.0 with Hadoop 2.2
quote: Patching Oozie's build so that you can create a package targetting Hadoop 2.2.0.
date: 2014-02-16 09:20:00 -05:00
categories:
  -- hadoop
---

The current version of Oozie (4.0.0) doesn't build correctly when you try and target Hadoop 2.2.
The Oozie team have a fix going into release 4.0.1 (see [OOZIE-1551](https://issues.apache.org/jira/browse/OOZIE-1551)),
but until then you can hack the Maven files to get it working with 4.0.0.

First download the 4.0.0 version from [https://oozie.apache.org/](https://oozie.apache.org/),
and then unpackage it. Next run the following
command to change the Hadoop version being targeted:

    cd oozie-4.0.0/
    find . -name pom.xml | xargs sed -ri 's/(2.2.0\-SNAPSHOT)/2.2.0/'

Now all you need to do is target the hadoop-2 profile in Maven and you'll be all set:

    mvn -DskipTests=true -P hadoop-2 clean package assembly:single

