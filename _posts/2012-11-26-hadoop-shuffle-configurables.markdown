---
layout: post
title: Configuring and tuning MapReduce's shuffle
quote: A look at the various MapReduce shuffle configurables, and where in the MapReduce process they are applied.
date: 2012-11-26 09:20:00 -05:00
categories:
  -- hadoop
---

Once you have outgrown your small Hadoop cluster it's worth tuning some of the shuffle
configurables to ensure that your performance keeps up with the physical growth of your
cluster. The figure below shows key configurables in the shuffle stage in Hadoop versions
1.x and earlier, and identifies those
that should be tuned.

![parition](/images/hadoop-shuffle-configurables.png)

You can read more about these configurables and their default values by looking at
[mapred-default.xml](http://hadoop.apache.org/docs/r1.0.3/mapred-default.html).
My book [Hadoop in Practice](http://www.manning.com/holmes/) (Manning Publications) in chapter
6  discusses how some of the configuration values in the figure should be tweaked when you start
working with mid to large-size Hadoop clusters.
