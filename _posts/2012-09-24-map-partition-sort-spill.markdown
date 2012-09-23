---
layout: post
title: How partitioning, collecting and spilling work in MapReduce
date: 2012-09-24 00:20:00 -05:00
categories:
  -- *nix
---

The figure below shows the various steps that the Hadoop MapReduce framework takes after your
map function emits a key/value output record. Please note that this figure represents what's
happening with Hadoop versions
1.x and earlier - in Hadoop 2.x there have been some changes which will be discussed
in a future blog post.

My book [Hadoop in Practice](http://www.manning.com/holmes/) (Manning Publications) in chapter
6  discusses how some of the configuration values in the figure should be tweaked when you start
working with mid to large-size Hadoop clusters.

![parition](/images/hadoopv1-partition-collect-spill.png)
