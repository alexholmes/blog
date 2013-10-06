---
layout: post
title: Bucketing, multiplexing and combining in Hadoop - part 2
date: 2013-07-16 09:20:00 -05:00
quote: In this part we examine the MultipleOutputs class for a more flexible way to write out multiple outputs from your mappers and reducers.
categories:
  -- hadoop
---

In the [first post of this series](http://grepalex.com/2013/05/20/multipleoutputs-part1/), we looked at how the `MultipleOutputFormat` class could be used in a task to write
to multiple output files. This approach had a few shortcomings which included that it couldn't be used in the map-side of a
job that used reducers, and it only worked with the old `mapred` API.

In this post we'll look at the `MultipleOutputs` class, which offers an alternative to the `MultipleOutputFormat` and
also addresses its shortcomings.

## MultipleOutputs

Using the `MultipleOutputs` class is a more modern Hadoop way of writing to multiple outputs. It has both
`mapred` and `mapreduce` API implementations, and allows you to work with multiple OutputFormat classes in your
job. Its approach is different from `MultipleOutputFormat` - rather than defining its own `OutputFormat` it
merely provides some helper methods which need to be called in your driver code, as well as in your mapper/reducer.

The two `MultipleOutputs` classes in `mapred` and `mapreduce` are close in functionality, the main difference being support
of multi-named outputs, which we'll examine later in this post.

Let's look at how we would achieve the same result as we did with `MultipleOutputFormat`. If you recall from the previous
post in this series, we were working with some sample data from a fruit market, where the data points were the location
of each market, and the fruit that was sold:

{% highlight bash %}
cupertino   apple
sunnyvale   banana
cupertino   pear
{% endhighlight %}

Our goal is to partition the outputs by city, so there would be city-specific files.
First up is our driver
code, where we need to tell `MultipleOutputs` the named outputs, and their related `OutputFormat` classes. For simplicity
we've chosen `TextOutputFormat` for both, but you can use different `OutputFormats` for each named output.

{% highlight java %}
MultipleOutputs.addNamedOutput(jobConf, "cupertino", TextOutputFormat.class, Text.class, Text.class);
MultipleOutputs.addNamedOutput(jobConf, "sunnyvale", TextOutputFormat.class, Text.class, Text.class);
{% endhighlight %}

The named outputs "cupertino" and "sunnyvale" are used for two purposes in `MultipleOutputs` - first as logical keys that you
use in your mapper and reducer to lookup their associated `OutputCollector` classes. And second, they are used as
the output filenames in HDFS.

We can't use an identity reducer in this example as we have to use the `MultipleOutputs` class to redirect our output
to the appropriate file, so let's go ahead and see what the reducer will look like.

{% highlight java %}
class Reduce extends MapReduceBase
        implements Reducer<Text, Text, Text, Text> {

    private MultipleOutputs output;

    @Override
    public void configure(final JobConf job) {
        super.configure(job);
        output = new MultipleOutputs(job);
    }

    @Override
    public void reduce(final Text key, final Iterator<Text> values,
                       final OutputCollector<Text, Text> collector, final Reporter reporter)
            throws IOException {
        while (values.hasNext()) {
            output.getCollector(key.toString(), reporter).collect(key, values.next());
        }
    }
}
{% endhighlight %}

As you can you're not using the `OutputCollector` supplied to us in the `reduce` method. Instead you create a `MultipleOutputs`
instance in the `configure` method which is used in the reduce method. For each reducer input record, we use the key
to lookup the `OutputCollector` and then emit each key/value pair to that collector. Remember that when calling
`getCollector` you must use one of the named outputs that you defined in the job driver. In our case our input keys are
either "cupertino" or "sunnyvale", and they map directly to the named outputs we defined in our driver, so we're in
good shape.

Let's examine the contents of the job output directory after running the job.

{% highlight bash %}
$ hadooop -lsr /output
/output/cupertino-r-00000
/output/sunnyvale-r-00000
/output/part-00000
/output/part-00001
{% endhighlight %}

This output highlights one of the key differences between `MultipleOutputs` and `MultipleOutputFormat`. When using
`MultipleOutputs` you can output to the reducer's regular `OutputCollector`, or to the `OutputCollector` for a named output, or to both,
which is why you see `part-nnnnn` files.

But wait! One problem with `MultipleOutputs` is that you needed to pre-define the partitions "cupertino" and "sunnyvale"
ahead of time in our driver. What if we didn't know the partitions ahead of time?

## Dynamic files with  the MultipleOutputs class

Up until now `MultipleOutputs` has treated us well - it supported both the old and new MapReduce API's, and can also
support multiple OutputFormat classes within the same reducer. But as we saw we essentially had to pre-define the
output files in our driver code. So how do we handle cases where we want this to be dynamically performed in the
reducer?

Luckily the `MultipleOutputs` has a notion of "multi named" output. In the driver method instead of enumerating all the
output files we want, we'll simply just add a single logical name called "fruit", using `addMultiNamedOutput` instead
of `addNamedOutput`:

{% highlight java %}
MultipleOutputs.addMultiNamedOutput(jobConf, "fruit", TextOutputFormat.class, Text.class, Text.class);
{% endhighlight %}

In our reducer we always specify "fruit" as the name, but we use a different `getCollector` method which takes an
additional field, which is used to determine the filename which is used for output:

{% highlight java %}
output.getCollector("fruit", key.toString(), reporter).collect(key, values.next());
{% endhighlight %}

Let's do another HDFS listing:

{% highlight bash %}
$ hadooop -lsr /output
/output/fruit_cupertino-r-00000
/output/fruit_sunnyvale-r-00000
/output/part-00000
/output/part-00001
{% endhighlight %}

Hurray! We now have multiple output files that are dynamically created based on the reducer output key, just like
we did with `MultipleOutputFormat`.

Now unfortunately the multi-named output is only supported by the old `mapred` API, whereas with the new `mapreduce`
API you are forced to define your partitions in your job driver.

## Conclusion

There are plenty of things to like about `MultipleOutputs`, namely its support for both "old" and "new" MapReduce API's,
and its support for multiple `OutputFormat` classes. Its only real downside is that multi named outputs are only
supported in the old `mapred` API, so those looking for dynamic partitions in the new `mapreduce` API are not supported
by either `MultipleOutputs` or `MultipleOutputFormat` described in [part 1](http://grepalex.com/2013/05/20/multipleoutputs-part1/).