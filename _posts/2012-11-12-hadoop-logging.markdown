---
layout: post
title: Controlling user logging in Hadoop
date: 2012-11-12 09:20:00 -05:00
categories:
  -- hadoop
---

Imagine that you're a Hadoop administrator, and to make things  interesting you're managing a
multi-tenant Hadoop cluster where data scientists, developers and QA
are pounding your cluster. One day you notice that your disks are filling-up fast,
and after some investigating you realize that the root cause is your MapReduce task logs.

How do you guard against this sort of thing happening? Before we get to that we need to understand
where these files exist, and how they're written. The figure below shows the three log files that
are created for each task in MapReduce. Notice that the logs are written to the local disk of the
task.

![parition](/images/hadoop-task-logs-location.png)

OK, so how does Hadoop normally make sure that our disks don't fill-up with these task logs?
I'll cover three approaches.

## Approach 1: mapred.userlog.retain.hours


With the `mapred.userlog.retain.hours` configurable, which is defined
in [mapred-default.xml](http://hadoop.apache.org/docs/r1.0.3/mapred-default.html) as:

> The maximum time, in hours, for which the user-logs are to be retained after the job completion.

Great, but what if your disks are filling up before Hadoop has had a chance to automatically clean them
up? It may be tempting to reduce `mapred.userlog.retain.hours` to a smaller value, but before you
do that you should know that there's a bug with the Hadoop versions 1.x and earlier
(see [MAPREDUCE-158](https://issues.apache.org/jira/browse/MAPREDUCE-158)), where the logs
for long-running jobs that run longer than `mapred.userlog.retain.hours` are accidentally deleted.
So maybe we should look elsewhere to solve our overflowing logs problem.

## Approach 2: mapred.userlog.limit.kb

Hadoop has another configurable, `mapred.userlog.limit.kb`, which can be used to limit the file
size of `stdlog`, which is the log4j log file. Let's peek again at the documentation:

> The maximum size of user-logs of each task in KB. 0 disables the cap.

The default value is `0`, which means that log writes go straight to the log file. So all we need to
do is to set a non-negative value and we're set, right? Not so fast - it turns out that this
approach has two disadvantages:

1. Hadoop and user logs are actually cached in memory, so you're taking away
`mapred.userlog.limit.kb` kilobytes worth of memory from your task's process.
2. Logs are only written out when the task process has completed, and only contain the last
`mapred.userlog.limit.kb` worth of log entries, so this can make it challenging to debug long-running
tasks.

OK, so what else can we try? We have one more solution, log levels.

## Approach 3: Changing log levels

Ideally all your Hadoop users got the memo about minimizing excessive logging. But the reality of
the situation is that you have limited control over what users decide to log in their code, but
what you do have control over is the task log levels.

If you had a MapReduce job that was aggressively logging in package `com.example.mr`, then you may
be tempted to use the _daemonlog_ CLI to connect to all the TaskTracker daemons and change the
logging to ERROR level:

    hadoop daemonlog -setlevel <host:port> com.example.mr ERROR

Yet again we hit a roadblock - this will only change the logging level for the TaskTracker process,
and not for the task process. Drat! This really only leaves one option, which is to update your
`${HADOOP_HOME}/conf/log4j.properties` on all your data nodes by adding the following line to this
file:

    log4j.logger.com.example.mr=ERROR

The great thing about this change is
that you don't need to restart MapReduce, since any new task processes will pick up your changes to
`log4j.properties`.
