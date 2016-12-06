---
layout: post
title: Configuring memory for MapReduce running on YARN
quote: This post examines the various memory configuration settings for your MapReduce job.
date: 2016-12-07 09:20:00 -05:00
categories:
  -- hadoop
---

The most common issue that I bump into these days when running MapReduce jobs is the following error:

```
Application application_1409135750325_48141 failed 2 times due to AM Container for
appattempt_1409135750325_48141_000002 exited with exitCode: 143 due to: Container
[pid=4733,containerID=container_1409135750325_48141_02_000001] is running beyond physical memory limits.
Current usage: 2.0 GB of 2 GB physical memory used; 6.0 GB of 4.2 GB virtual memory used. Killing container.
```

Reading that message it's pretty clear that your job has exceeded its memory limits, but how do you go about
fixing this?

# Make sure your job has to cache data

Before we start tinkering with configuration settings, take a moment to think about what your job is doing.
Your map or reduce task running out of memory usually means that data is being cached in your map or reduce tasks. Data can
be cached for a number of reasons:

* Your job is writing out Parquet data, and Parquet buffers data in memory prior to writing it out to disk
* Your code (or a library you're using) is caching data.  An example here is joining two datasets together
where one dataset is being cached prior to joining it with the other.

Therefore the first step I'd suggest you take is to think about whether you really need to cache data, and if it's
possible to reduce your memory utilization without too much work.  If that's possible you may want to consider doing
that prior to bumping-up the memory for your job.

# How YARN monitors the memory of your container

This section isn't specific to MapReduce, it's an overview of how YARN generally monitors memory for running
containers (in MapReduce a container is either a map or reduce process).

Each slave node in your YARN cluster runs a _NodeManager_ daemon, and one of the _NodeManager_'s roles is to
monitor the YARN containers running on the node. One part of this work is monitoring the memory utilization of
each container.

To do this the _NodeManager_ periodically (every 3 seconds by default, which can be changed via
`yarn.nodemanager.container-monitor.interval-ms`) cycles through all the currently running containers, calculates
the process tree (all child processes for each container), and for each process
examines the `/proc/<PID>/stat` file (where PID is the process ID of the
container) and extracts the physical memory (aka RSS) and the virtual memory (aka VSZ or VSIZE).

If virtual memory checking is enabled (true by default, overridden via `yarn.nodemanager.vmem-check-enabled`),
then YARN compares the summed VSIZE extracted from the container process (and all child processes) with the maximum
allowed virtual memory for the container.
The maximum allowed virtual memory is basically the configured maximum physical memory for the container multiplied
by `yarn.nodemanager.vmem-pmem-ratio` (default is 2.1).  So if your YARN container is configured
to have a maximum of 2 GB of physical memory, then this number is multiplied by 2.1 which means you are allowed to
use 4.2 GB of virtual memory.

If physical memory checking is enabled (true by default, overridden via `yarn.nodemanager.pmem-check-enabled`),
then YARN compares the summed RSS extracted from the container process (and all child processes) with the maximum
allowed physical memory for the container.

If either the virtual or physical utilization is higher than the maximum permitted, YARN will kill the container,
as shown at the top of this article.

# Increasing the memory availble to your MapReduce job

Back in the days when MapReduce didn't run on YARN memory configuration was pretty simple, but these days
MapReduce runs as a YARN application and things are a little bit more involved.  For MapReduce running on YARN
there are actually two memory settings you have to configure at the same time:

1.  The physical memory for your YARN map and reduce processes
2.  The JVM heap size for your map and reduce processes

## Physical memory for your YARN map and reduce processes

Configure `mapreduce.map.memory.mb` and `mapreduce.reduce.memory.mb` to set the YARN container physical memory limits
for your map and reduce processes respectively.  For example if you want to limit your map process to 2GB and your
reduce process to 4GB, and you wanted that to be the default in your cluster, then you'd set the following in `mapred-site.xml`:

```
<property>
  <name>mapreduce.map.memory.mb</name>
  <value>2048</value>
</property>
<property>
  <name>mapreduce.reduce.memory.mb</name>
  <value>4096</value>
</property>
```

The physical memory configured for your job must fall within the minimum and maximum memory allowed for containers in
your cluster (check the `yarn.scheduler.maximum-allocation-mb` and `yarn.scheduler.minimum-allocation-mb` properties
respectively).

## JVM heap size for your map and reduce processes

Next you need to configure the JVM heap size for your map and reduce processes.  These sizes need to be less than the
physical memory you configured in the previous section.  As a general rule they should be 80% the size of the YARN
physical memory settings.

Configure `mapreduce.map.java.opts` and `mapreduce.reduce.java.opts` to set the map and reduce heap sizes respectively.
To continue the example from the previous section, we'll take the 2GB and 4GB physical memory limits and multiple by
0.8 to arrive at our Java heap sizes.  So we'd end up with the following in `mapred-site.xml` (assuming you wanted
these to be the defaults for your cluster):

```
<property>
  <name>mapreduce.map.java.opts</name>
  <value>-Xmx1638m</value>
</property>
<property>
  <name>mapreduce.reduce.java.opts</name>
  <value>-Xmx3278m</value>
</property>
```


## Configuring settings for your job

The same configuration properties that I've described above apply if you want to individually configure your MapReduce
jobs and override the cluster defaults.  Again you'll want to set values for these properties for your job:

| Property        | Description           |
| ------------- |:-------------:|
| `mapreduce.map.memory.mb` | The amount of physical memory that your YARN map process can use. |
| `mapreduce.reduce.memory.mb` | The amount of physical memory that your YARN reduce process can use. |
| `mapreduce.map.java.opts` | Used to configure the heap size for the map JVM process.  Should be 80% of `mapreduce.map.memory.mb`.|
| `mapreduce.reduce.java.opts` | Used to configure the heap size for the reduce JVM process. Should be 80% of `mapreduce.reduce.memory.mb`.|

