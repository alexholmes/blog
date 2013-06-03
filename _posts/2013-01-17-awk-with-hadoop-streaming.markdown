---
layout: post
title: Using awk and friends with Hadoop
quote: How to use Linux tools such as awk in MapReduce.
date: 2013-01-17 09:20:00 -05:00
categories:
  -- hadoop
---

Imagine you have a CSV file that you want to manipulate. Here's a sample file we can play with:

    lopez,charlie,2002,11,21
    parker,ward,1995,04,08
    henderson,russell,2007,10,01

Our goal is to transform this into the following form by combining the last three
columns:

    lopez,charlie,20021121
    parker,ward,19950408
    henderson,russell,20071001

In Linux this would take all of two seconds (excuse the awkward awk command):

    shell$ awk -F"," '{ print $1","$2","$3$4$5 }' people.txt

What if you wanted to quickly do the same in HDFS - and let's assume you want to write the
results back to HDFS. One approach would be to use the HDFS CLI to stream the inputs into
awk, and stream the awk output back into HDFS. You could do this with the HDFS `cat` and `put -` options
(note that adding a hyphen after `put` instructs the put command to stream data from standard input to
HDFS):

    shell$ hadoop fs -cat people.txt | awk -F"," '{ print $1","$2","$3$4$5 }' | hadoop fs -put - people-coalesed.txt

BTW, if your input and output files are LZOP-compressed then this command would work:

    shell$ hadoop fs -cat people.txt.lzo | lzop -dc | awk -F"," '{ print $1","$2","$3$4$5 }' | \
             lzop -c | hadoop fs -put - people-coalesed.txt.lzo


This is great if your file isn't too large, but if it's multiple gigabytes in length then you
probably want to harness the power of MapReduce to get this done in a jiffy! The words "in a jiffy"
and "MapReduce" aren't commonly used together, so what do we do? Well you could crack open Pig or
Hive and write some custom user-defined functions, but this means you end up in Java which we want to
avoid.

Hadoop Streaming comes to the rescue in these situations.  Let's first create our awk script which will be executed:

    shell$ cat people.awk
    #!/bin/awk -f

    BEGIN { FS = "," }
    { print $1","$2","$3$4$5 }

In Linux, if you make this awk script executable, you could execute is as follows:

    shell$ ./people.awk people.txt

In MapReduce-land we don't need to join data in this particular example, so we don't need to run any reducers.
Call your awk script from mappers via [Hadoop Streaming](http://hadoop.apache.org/docs/mapreduce/current/streaming.html) with this command:

    shell$ HADOOP_HOME=/usr/lib/hadoop
    shell$ ${HADOOP_HOME}/bin/hadoop \
      jar ${HADOOP_HOME}/contrib/streaming/*.jar \
      -D mapreduce.job.reduces=0 \
      -D mapred.reduce.tasks=0 \
      -input people.txt \
      -output people-coalesed \
      -mapper people.awk \
      -file people.awk

You can view the output in HDFS with a `cat`:

    shell$ hadoop fs -cat /user/aholmes/people-coalesed/part*
    henderson,russell,20071001
    lopez,charlie,20021121
    parker,ward,19950408

A few options in the Hadoop Streaming command are worth examining:

![awk-streaming-image](/images/awk-streaming.png)

Finally - to get LZO into the picture you need to add `-inputformat`,
 `-D mapred.output.compress` and `-D mapred.output.compression.codec` arguments:


    shell$ HADOOP_HOME=/usr/lib/hadoop
    shell$ ${HADOOP_HOME}/bin/hadoop \
      jar ${HADOOP_HOME}/contrib/streaming/*.jar \
      -D mapreduce.job.reduces=0 \
      -D mapred.reduce.tasks=0 \
      -D mapred.output.compress=true \
      -D stream.map.input.ignoreKey=true \
      -D mapred.output.compression.codec=com.hadoop.compression.lzo.LzopCodec \
      -inputformat com.hadoop.mapred.DeprecatedLzoTextInputFormat \
      -input people.txt.lzo \
      -output people-coalesed \
      -mapper people.awk \
      -file people.awk
