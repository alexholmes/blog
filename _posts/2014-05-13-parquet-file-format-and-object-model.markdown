---
layout: post
title: Understanding how Parquet integrates with Avro, Thrift and Protocol Buffers
quote: Parquet offers integration with a number of object models, and this post shows how Parquet supports various object models.
date: 2014-05-13 09:20:00 -05:00
categories:
  -- hadoop
---

[Parquet](http://parquet.io/) is a new columnar storage format that come out of a collaboration between Twitter and Cloudera.
Parquet's generating a lot of excitement in the community for good reason - it's shaping up to be the next
big thing for data storage in Hadoop for a number of reasons:

1. It's a sophisticated columnar file format, which means that it's well-suited to OLAP workloads, or really any workload where
projection is a normal part of working with the data.
2. It has a high level of integration with Hadoop and the ecosystem - you can work with Parquet in MapReduce, Pig,
Hive and Impala.
3. It supports Avro, Thrift and Protocol Buffers.

The last item raises a question - how does Parquet work with Avro and friends?
Parquet is actually a *storage format* (with a [formal file format](https://github.com/Parquet/parquet-format) ),
and integrates with the Avro, Thrift and Protocol Buffers *object models*.

![Image of storage formats and object models](/images/parquet_storage_object.png)

Avro, Thrift and Protocol Buffers all have have their own storage formats, but Parquet doesn't utilize them in any
way. Parquet data is always serialized using its own file format. This is why Parquet can't read files serialized using
Avro's storage format, and vice-versa.

So how does Parquet allow you to work with Avro, yet persist data using its own file format?
That's where Parquet _converters_ come into the picture - their job is to map object model instances
to Parquet's internal values (and vice-versa). Let's examine what happens when you write an Avro object to Parquet:

![Avro/Parquet write path](/images/parquet_avro_write.png)

The Avro converter stores within the Parquet file's metadata the schema for the objects being written. You can see
this by using a Parquet CLI to dumps out the Parquet metadata contained within a Parquet file.

    $ export HADOOP_CLASSPATH=parquet-avro-1.4.3.jar:parquet-column-1.4.3.jar:parquet-common-1.4.3.jar:parquet-encoding-1.4.3.jar:parquet-format-2.0.0.jar:parquet-generator-1.4.3.jar:parquet-hadoop-1.4.3.jar:parquet-hive-bundle-1.4.3.jar:parquet-jackson-1.4.3.jar:parquet-tools-1.4.3.jar

    $ hadoop parquet.tools.Main meta stocks.parquet
    creator:     parquet-mr (build 3f25ad97f209e7653e9f816508252f850abd635f)
    extra:       avro.schema = {"type":"record","name":"Stock","namespace" [more]...

    file schema: hip.ch5.avro.gen.Stock
    --------------------------------------------------------------------------------
    symbol:      REQUIRED BINARY O:UTF8 R:0 D:0
    date:        REQUIRED BINARY O:UTF8 R:0 D:0
    open:        REQUIRED DOUBLE R:0 D:0
    high:        REQUIRED DOUBLE R:0 D:0
    low:         REQUIRED DOUBLE R:0 D:0
    close:       REQUIRED DOUBLE R:0 D:0
    volume:      REQUIRED INT32 R:0 D:0
    adjClose:    REQUIRED DOUBLE R:0 D:0

    row group 1: RC:45 TS:2376
    --------------------------------------------------------------------------------
    symbol:       BINARY UNCOMPRESSED DO:0 FPO:4 SZ:84/84/1.00 VC:45 ENC:B [more]...
    date:         BINARY UNCOMPRESSED DO:0 FPO:88 SZ:198/198/1.00 VC:45 EN [more]...
    open:         DOUBLE UNCOMPRESSED DO:0 FPO:286 SZ:379/379/1.00 VC:45 E [more]...
    high:         DOUBLE UNCOMPRESSED DO:0 FPO:665 SZ:379/379/1.00 VC:45 E [more]...
    low:          DOUBLE UNCOMPRESSED DO:0 FPO:1044 SZ:379/379/1.00 VC:45  [more]...
    close:        DOUBLE UNCOMPRESSED DO:0 FPO:1423 SZ:379/379/1.00 VC:45  [more]...
    volume:       INT32 UNCOMPRESSED DO:0 FPO:1802 SZ:199/199/1.00 VC:45 E [more]...
    adjClose:     DOUBLE UNCOMPRESSED DO:0 FPO:2001 SZ:379/379/1.00 VC:45  [more]...

The "avro.schema" is where the Avro schema information is stored. This allows the Avro Parquet reader the ability to
marshall Avro objects without the client having to supply the schema.

You can also use the "schema" command to view the Parquet schema.

    $ hadoop parquet.tools.Main schema stocks.parquet
    message hip.ch4.avro.gen.Stock {
      required binary symbol (UTF8);
      required binary date (UTF8);
      required double open;
      required double high;
      required double low;
      required double close;
      required int32 volume;
      required double adjClose;
    }

This tool is useful when loading a Parquet file into Hive, as you'll need to use the field names defined in the Parquet
schema when defining the Hive table (note that the syntax below only works with Hive 0.13 and newer).

    hive> CREATE EXTERNAL TABLE parquet_stocks(
        symbol string,
        date string,
        open double,
        high double,
        low double,
        close double,
        volume int,
        adjClose double
    ) STORED AS PARQUET
    LOCATION '...';