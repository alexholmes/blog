---
layout: post
title: Using the libjars option with Hadoop
date: 2013-02-25 09:20:00 -05:00
categories:
  -- hadoop
---

When working with MapReduce one of the challenges that is encountered early-on is determining
how to make your third-part JAR's available to the map and reduce tasks. One common approach is to
create a _fat jar_, which is a JAR that contains your classes as well as your
third-party classes (see [this Cloudera blog post](http://blog.cloudera.com/blog/2011/01/how-to-include-third-party-libraries-in-your-map-reduce-job/)
for more details).

A more elegant solution is to take advantage of the `libjars` option in the `hadoop jar` command,
also mentioned in the Cloudera post at a high level.
Here I'll go into detail on the three steps required to make this work.

# Add libjars to the options

It can be confusing to know exactly where to put `libjars` when running the `hadoop jar` command.
The following example shows the correct position of this option:

{% highlight bash %}
$ export LIBJARS=/path/jar1,/path/jar2
$ hadoop jar my-example.jar com.example.MyTool -libjars ${LIBJARS} -mytoolopt value
{% endhighlight %}

It's worth noting in the above example that the JAR's supplied as the value of the `libjar` option
are *comma-separated*, and not separated by your O.S. path delimiter (which is how a Java
classpath is delimited).

You may think that you're done, but often times this step alone may not be enough - read on for more details!

# Make sure your code is using GenericOptionsParser

The Java class that's being supplied to the `hadoop jar` command should use the
[GenericOptionsParser](http://hadoop.apache.org/docs/stable/api/org/apache/hadoop/util/GenericOptionsParser.html)
class to parse the options being supplied on the CLI.
The easiest way to do that is demonstrated with the following code, which leverages the
[ToolRunner](http://hadoop.apache.org/docs/stable/api/org/apache/hadoop/util/ToolRunner.html)
class to parse-out the options:

{% highlight java %}
public static void main(final String[] args) throws Exception {
  Configuration conf = new Configuration();
  int res = ToolRunner.run(conf, new com.example.MyTool(), args);
  System.exit(res);
}
{% endhighlight %}

It is **crucial** that the configuration object being passed into the `ToolRunner.run` method
is the same one that you're using when setting-up your job. To guarantee this, your class should
use the `getConf()` method defined in `Configurable` (and implemented `Configured`)
to access the configuration:

{% highlight java %}
public class SmallFilesMapReduce extends Configured implements Tool {

  public final int run(final String[] args) throws Exception {
        Job job = new Job(getConf());
        ...
  }
{% endhighlight %}

If you don't leverage the Configuration object supplied to the `ToolRunner.run` method in your
MapReduce driver code, then your job won't be correctly configured and your third-party
JAR's won't be copied to the Distributed Cache or loaded in the remote task JVM's.

It's the `ToolRunner.run` method (actually it delegates the command parsing to `GenericOptionsParser`)
which actually parses-out the `libjars` argument, and adds to the Configuration object  a value for
the `tmpjar` property. So a quick way to make sure that this step is working is to look at the job file for
your MapReduce job (there's a link when viewing the job details from the JobTracker), and make sure
that the `tmpjar` configuration name exists with a value identical to the path that you specified in
your command.  You can also use the command-line to search for the `libjars` configuration in HDFS

{% highlight bash %}
$ hadoop fs -cat <JOB_OUTPUT_HDFS_DIRECTORY>/_logs/history/*.xml | grep tmpjars
{% endhighlight %}

# Use HADOOP_CLASSPATH to make your third-party JAR's available on the client-side

So far the first two steps tackled what you needed to do to to make your third-party JAR's available to
the remote map and reduce task JVM's. But what hasn't been covered so far is making these same JAR's
available to the client JVM, which is the JVM that's created when you run the `hadoop jar` command.

For this to happen, you should set the `HADOOP_CLASSPATH` environment variable to contain the
O.S. path-delimited list of third-party JAR's. Let's extend the commands in the first step above
with the addition of setting the `HADOOP_CLASSPATH` environment variable:

{% highlight bash %}
$ export LIBJARS=/path/jar1,/path/jar2
$ export HADOOP_CLASSPATH=/path/jar1:/path/jar2
$ hadoop jar my-example.jar com.example.MyTool -libjars ${LIBJARS} -mytoolopt value
{% endhighlight %}

Note that value for `HADOOP_CLASSPATH` uses a Unix path delimiter of `:`, so modify
accordingly for your platform. And if you don't like the copy-paste above you could modify
that line to substitute the commas for semi-colons:

{% highlight bash %}
$ export HADOOP_CLASSPATH=`echo ${LIBJARS} | sed s/,/:/g`
{% endhighlight %}

