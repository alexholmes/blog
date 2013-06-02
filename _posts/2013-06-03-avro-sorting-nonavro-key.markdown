---
layout: post
title: Secondary sorting with Avro
quote: Complete control over how partitioning, sorting and grouping work with Avro map output keys.
date: 2013-06-03 09:20:00 -05:00
categories:
  -- avro
  -- hadoop
---

In the [last Avro sorting post](http://grepalex.com/2013/05/28/avro-builtin-sorting/)
 you saw how sorting Avro records works in MapReduce, and how one can ignore fields in
Avro records for partitioning, sorting and grouping. In the process you discovered that ignored fields
are limited by being immutable (since they can only be defined once for a schema), which means you
can't vary what fields are ignored
for partitioning, sorting or grouping, which is key for secondary sort.

If you wish to use secondary sort with Avro, one option would be to emit a custom Writable as the map
output key, and emit an Avro record as the map output value. With this approach you'd write a custom
partitioner, and sorting/grouping implementation.

This post looks at another option, where with some hacking you can actually have secondary sort with Avro map output keys.

## True secondary sort with an AvroKey

Avro has some utility classes for sorting and hashing (required for the partitioner), but the code is locked-down with
private methods. The hacking therefore requires lifting certain parts of Avro's code, and writing some helper functions
to easily allow jobs fine-grained control over what fields are used for secondary sort.

Let's take an example with the same Avro schema we used in the last post:

{% highlight json %}
{"type": "record", "name": "com.alexholmes.avro.WeatherNoIgnore",
 "doc": "A weather reading.",
 "fields": [
     {"name": "station", "type": "string"},
     {"name": "time", "type": "long"},
     {"name": "temp", "type": "int"},
     {"name": "counter", "type": "int", "default": 0}
 ]
}
{% endhighlight %}

For secondary sort you may imagine a scenario where you want to partition output records by the station, sort
records using the station, time and temp fields, and finally group by the station and time fields. The code
to do this is as follows  [GitHub source](https://github.com/alexholmes/avro-sorting/blob/master/src/main/java/com/alexholmes/avro/sort/avrokey/AvroSortCustom.java):

{% highlight java %}
AvroSort.builder()
    .setJob(job)
    .addPartitionField(WeatherNoIgnore.SCHEMA$, "station", true)
    .addSortField(WeatherNoIgnore.SCHEMA$, "station", true)
    .addSortField(WeatherNoIgnore.SCHEMA$, "time", true)
    .addSortField(WeatherNoIgnore.SCHEMA$, "temp", true)
    .addGroupField(WeatherNoIgnore.SCHEMA$, "station", true)
    .addGroupField(WeatherNoIgnore.SCHEMA$, "time", true)
    .configure();
{% endhighlight %}

The ordering of the `addXXX` calls is significant, as it determines the order in which fields are used for sorting and
grouping. The last argument in the `addXXX` methods is a boolean which indicates whether the ordering is ascending.

Most of the heavy lifting is performed in the
[AvroSort](https://github.com/alexholmes/avro-sorting/blob/master/src/main/java/com/alexholmes/avro/sort/avrokey/AvroSort.java)
 and
 [AvroDataHack](https://github.com/alexholmes/avro-sorting/blob/master/src/main/java/org/apache/avro/io/AvroDataHack.java)
 - the latter, as its name indicates, is where some hacking took place to get things working.

The only caveat with the current implementation is that Avro union types aren't currently supported - I'll look
into that in the near future.
