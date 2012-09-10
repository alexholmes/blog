---
layout: post
title: Sorting text files with MapReduce
date: 2012-09-10 08:00:00 -05:00
categories:
  -- hadoop
---

In my [last post](http://grepalex.com/2012/09/01/sorting-large-files-in-linux/) I wrote about
sorting files in Linux. Decently large files (in the tens of GB's) can be sorted fairly quickly using
that approach. But what if your files are already in HDFS, or ar hundreds of GB's in size or larger?
In this case it makes sense to use MapReduce and leverage your cluster resources to sort your data
in parallel.

MapReduce should be thought of as a ubiquitous sorting tool, since by design it sorts all the
map output records (using the map output keys), so that all the records that reach a single reducer
are sorted. The diagram below shows the internals of how the shuffle phase works in MapReduce.

![shuffle in MapReduce](/images/sorting-files-mapreduce-internals.png)

Given that MapReduce already performs sorting between the map and reduce phases, then sorting files
can be accomplished with an identity function (one where the inputs to the map and reduce phases
are emitted directly). This is in fact what the _sort_ example that is bundled with Hadoop does.
You can look at the how the example code works by examining the [org.apache.hadoop.examples.Sort](http://svn.apache.org/viewvc/hadoop/common/tags/release-1.0.3/src/examples/org/apache/hadoop/examples/Sort.java?view=markup)
class. To use this example code to sort text files in Hadoop, you would use it as follows:

    shell$ export HADOOP_HOME=/usr/lib/hadoop
    shell$ $HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/hadoop-examples.jar sort \
             -inFormat org.apache.hadoop.mapred.KeyValueTextInputFormat \
             -outFormat org.apache.hadoop.mapred.TextOutputFormat \
             -outKey org.apache.hadoop.io.Text \
             -outValue org.apache.hadoop.io.Text \
             /hdfs/path/to/input \
             /hdfs/path/to/output

This works well, but it doesn't offer some of the features that I commonly rely upon in Linux's
sort, such as sorting on a specific column, and case-insensitive sorts.

## Linux-esque sorting in MapReduce

I've started a new GitHub repo called  [hadoop-utils](https://github.com/alexholmes/hadoop-utils),
where I plan to roll useful helper classes and utilities. The first one is a flexible Hadoop sort.
The same Hadoop example sort can be accomplished with the hadoop-utils sort as follows:

    shell$ $HADOOP_HOME/bin/hadoop jar hadoop-utils-<version>-jar-with-dependencies.jar \
             com.alexholmes.hadooputils.sort.Sort \
             /hdfs/path/to/input \
             /hdfs/path/to/output

To bring sorting in MapReduce closer to the Linux sort, the `--key` and `--field-separator` options
can be used to specify one or more columns that should be used for sorting, as well as a custom
separator (whitespace is the default). For example, imagine you had a file in HDFS called `/input/300names.txt`
which contained first and last names:

    shell$ hadoop fs -cat 300names.txt | head -n 5
           Roy     Franklin
           Mario   Gardner
           Willis  Romero
           Max     Wilkerson
           Latoya  Larson

To sort on the last name you would run:

    shell$ $HADOOP_HOME/bin/hadoop jar hadoop-utils-<version>-jar-with-dependencies.jar \
             com.alexholmes.hadooputils.sort.Sort \
             --key 2 \
             /input/300names.txt \
             /hdfs/path/to/output

The syntax of `--key` is `POS1[,POS2]`, where the first position (POS1) is required, and the second
position (POS2) is
optional - if it's omitted then `POS1` through the rest of the line is used for sorting.
Just like the Linux sort, `--key` is 1-based, so `--key 2` in the above example will sort on the
second column in the file.


## LZOP integration

Another trick that this sort utility has is its tight integration with LZOP, a useful compression
codec that works well with large files in MapReduce (see chapter 5 of
[Hadoop in Practice](http://www.manning.com/holmes/) for more details on LZOP). It can work with
LZOP input files that span multiple splits, and can also LZOP-compress outputs, and even create
LZOP index files. You would do this with the `codec` and `lzop-index` options:

    shell$ $HADOOP_HOME/bin/hadoop jar hadoop-utils-<version>-jar-with-dependencies.jar \
             com.alexholmes.hadooputils.sort.Sort \
             --key 2 \
             --codec com.hadoop.compression.lzo.LzopCodec \
             --map-codec com.hadoop.compression.lzo.LzoCodec \
             --lzop-index \
             /hdfs/path/to/input \
             /hdfs/path/to/output

## Multiple reducers and total ordering

If your sort job runs with multiple reducers (either because `mapreduce.job.reduces` in `mapred-site.xml`
has been set to a number larger than 1, or because you've used the `-r` option to specify the number
of reducers on the command-line), then by default Hadoop will use the
[HashPartitioner](http://hadoop.apache.org/common/docs/r1.0.3/api/org/apache/hadoop/mapred/lib/HashPartitioner.html)
to distribute records across the reducers.
Use of the HashPartitioner means that you can't concatenate your output files to create a single sorted
output file. To do this you'll need _total ordering_, which is supported by both the
Hadoop example sort and the hadoop-utils sort - the hadoop-utils sort enables this with the `--total-order` option.

    shell$ $HADOOP_HOME/bin/hadoop jar hadoop-utils-<version>-jar-with-dependencies.jar \
             com.alexholmes.hadooputils.sort.Sort \
             --total-order 0.1 10000 10 \
             /hdfs/path/to/input \
             /hdfs/path/to/output


The syntax is for this option is unintuitive so let's look at what each field means.

![sampling image](/images/sorting-files-mapreduce-sampling.png)


More details on total ordering can be seen in chapter 4 of [Hadoop in Practice](http://www.manning.com/holmes/).

## More details

For details on how to download and run the hadoop-utils sort take a look at the
[CLI guide](https://github.com/alexholmes/hadoop-utils/blob/master/CLI.md) in the
[GitHub project page](https://github.com/alexholmes/hadoop-utils).




