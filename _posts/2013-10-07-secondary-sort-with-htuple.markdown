---
layout: post
title: Simplifying secondary sorting in MapReduce with htuple
quote: Introducing htuple, an open-source project to simplify secondary sorting in MapReduce.
date: 2013-10-07 09:20:00 -05:00
categories:
  -- hadoop
---

I've recently found myself immersed in writing a number of MapReduce jobs that all require secondary sort.
Whilst I was nursing my cramping hands after writing what felt like the 100th custom Writable (and supporting partitioner/comparators),
a thought occurred to me - "surely there's a better way"?  As I started thinking about this some more, I realized
that what I needed was a general-purpose mechanism that would allow me to:

1. Work with compound elements
2. Provide pre-built partitioners and comparators that would know how to work with these compound elements
3. Model all of this in a way that is easy to read and understand

This is the inspiration behind [htuple](https://github.com/alexholmes/htuple), a small project that I just open-sourced.

## htuple

Let me give you an example of how you can use `htuple` to perform secondary sorting.  Imagine that you have a dataset
which contains last and first names:

    Smith	John
    Smith	Anne
    Smith	Ken

One example aggregation you may want to perform on this data is to count the number of distinct first names for each
last name. A reasonable approach to implementing this in MapReduce would be to emit the last name as the mapper output key,
the first name as the mapper output value, and in the reducer you'd collect all the first names in a set and then count them. This would work fine when working
with names, but what if your dataset had some keys with a large number of distinct values - large enough that you
run into problems caching all the data in the reducer's memory?

One solution here would be to use secondary sort - and in the example of our names, sort the first names so that the
reducer wouldn't need to store them in a set (instead it can just increment a count as it's reading the first names). In this
case you'd probably end up writing a custom `Writable`
which would contain both the last name and first name, and you'd also write a custom partitioner, and a sorting
and grouping comparator. Phew, that's a lot of work just to get secondary sort working.

Let's examine how you'd use `htuple` to do this work. First of all, I'd recommend defining an enum to create logical
names for the elements you'll store in the tuple. In our case we need two elements for the names, so here goes:

{% highlight java %}
/**
 * User-friendly names that we can use to refer to fields in the tuple.
 */
enum TupleFields {
    LAST_NAME,
    FIRST_NAME
}
{% endhighlight %}

The first concept we'll introduce in `htuple` is the `Tuple` class. This class is merely a container for reading and
writing multiple elements, and will be the class that you'll use to emit keys from your mapper. There are three ways
you can write data into this tuple - here we'll cover what I think is the most useful method, which is using the
enum you just created. Let's see how this will work in our mapper.

{% highlight java %}
public static class Map extends Mapper<LongWritable, Text, Tuple, Text> {

    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        // tokenize the line
        String nameParts[] = value.toString().split("\t");

        // create the tuple, setting the first and last names
        Tuple outputKey = new Tuple();
        outputKey.set(TupleFields.LAST_NAME, nameParts[0]);
        outputKey.set(TupleFields.FIRST_NAME, nameParts[1]);

        // emit the tuple and the original contents of the line
        context.write(outputKey, value);
    }
}
{% endhighlight %}

The first thing you do in your mapper is split the input line, where the first token is the last name, and the second
token is the first name. Next you create a new `Tuple` object and set the last and first name. We're using the enum
to logically refer to the fields. What's happening beneath the scenes is that the `Tuple` class is using the
<a href="http://docs.oracle.com/javase/7/docs/api/java/lang/Enum.html#ordinal()">ordninal value</a>
of the enum to determine the
position in the ArrayList to set. So that means `LAST_NAME`, which has an ordinal position of `0`, will have its value
set in index `0` in the `Tuple` classes underlying `ArrayList`.

Now that you've emitted your Tuple in the mapper, you need to configure your job for secondary sort. This will then expose
you to the second class in `htuple`, `ShuffleUtils`. `ShuffleUtils` allows you to specify which elements
in your tuple are used for partitioning, sorting and grouping during the shuffle phase.  And this is how you do it:

{% highlight java %}
ShuffleUtils.configBuilder()
    .useNewApi()
    .setPartitionerIndices(TupleFields.LAST_NAME)
    .setSortIndices(TupleFields.values())
    .setGroupIndices(TupleFields.LAST_NAME)
    .configure(conf);
{% endhighlight %}

If you recall how secondary sort works (see my book "[Hadoop in Practice](http://www.manning.com/holmes/)" for a detailed
explanation), you need to perform three steps in your MapReduce driver:

1. Specify how your compound key will be partitioned. In our example we only want the partitioner to use the last name
so that all records with the same last name get routed to the same reducer.
2. Specify how your compound key will be sorted. Here we want both the last and first name to be sorted, so that the
first names will be presented to your reducer in sorted order.
3. Specify how your compound key will be grouped. Since we want all the first names to be streamed to a single reducer
invocation for a given last name, we only want to group on the last name.

A couple of things worth noting in the above code example:

1.  We're using the new MapReduce API (i.e. using package `org.apache.hadoop.mapreduce`), and as such you need to call the `useNewApi` method.
2.  The `values` method on an enum returns an array of all of the enum fields in order of definition, which in our example is the last
name followed by the first name - exactly the order in which we want the sorting to occur.

You're done! If you examine the output of the MapReduce job in HDFS you'll see that indeed all the records are sorted by last
and first name.

    $ hadoop fs -cat output/part*
    Smith	Anne
    Smith	John
    Smith	Ken

You can look at the complete source in [SecondarySort.java](https://github.com/alexholmes/htuple/blob/master/examples/src/main/java/org/htuple/examples/SecondarySort.java).
The [htuple github page](https://github.com/alexholmes/htuple) has instructions for downloading, building and running this same example in a couple of easy steps.
There's also a page which shows the [types supported by htuple](https://github.com/alexholmes/htuple/blob/master/DATATYPES.md).