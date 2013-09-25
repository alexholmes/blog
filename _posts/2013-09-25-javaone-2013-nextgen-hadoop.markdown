---
layout: post
title: Next Generation Hadoop - It's Not Just Batch!
date: 2013-09-25 09:20:00 -05:00
categories:
  -- hadoop
---

In my JavaOne talk today I presented changes that are happening in Hadoop, where it's shaking off it's batch-based
shackles and enabling a new Hadoop platform that can support a mix of processing systems, from stream-processing
systems to NoSQL systems.

The slides for my talk can be viewed on [Speaker Deck](https://speakerdeck.com/alexholmes/javaone-2013-presentation-next-generation-hadoop-its-not-just-batch). The rest of this post is an overview of the technologies covered
in my talk, along with links for further reading.

## YARN

With Hadoop 2.x, we now have YARN which acts as a distributed scheduler. This is a big step towards the vision of
Hadoop being the Big Data Kernel, as it allows arbitrary applications to be scheduled on the same Hadoop cluster,
and enables a new world where we can have silo'd applications coexisting on the same hardware and sharing the same
storage.

The following links serve as a good starting ground to learn more about YARN:

* An introduction to YARN: [http://hortonworks.com/blog/introducing-apache-hadoop-yarn/](http://hortonworks.com/blog/introducing-apache-hadoop-yarn/)
* A book by Arun Murthy et. al. on YARN: [http://www.amazon.com/Apache-Hadoop-YARN-Processing-Addison-Wesley/dp/0321934504](http://www.amazon.com/Apache-Hadoop-YARN-Processing-Addison-Wesley/dp/0321934504),
first chapter can be read for free at [http://hortonworks.com/wp-content/uploads/downloads/2013/06/Apache.Hadoop.YARN_.Sample.pdf](http://hortonworks.com/wp-content/uploads/downloads/2013/06/Apache.Hadoop.YARN_.Sample.pdf).
* The YARN ResourceManager: [http://hortonworks.com/blog/apache-hadoop-yarn-resourcemanager/](http://hortonworks.com/blog/apache-hadoop-yarn-resourcemanager/)
* Writing YARN applications: [http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/WritingYarnApplications.html](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/WritingYarnApplications.html)
* Setting up a cluster to run MapReduce on YARN: [http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html)
* Configuring YARN: [http://hortonworks.com/blog/how-to-plan-and-configure-yarn-in-hdp-2-0/](http://hortonworks.com/blog/how-to-plan-and-configure-yarn-in-hdp-2-0/)
* Default YARN configuration: [http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-common/yarn-default.xml](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)
* YARN commands: [http://archive.cloudera.com/cdh4/cdh/4/hadoop/hadoop-yarn/hadoop-yarn-site/YarnCommands.html](http://archive.cloudera.com/cdh4/cdh/4/hadoop/hadoop-yarn/hadoop-yarn-site/YarnCommands.html)

## Apache HBase

HBase is a NoSQL, distributed multi-dimensional map based on Google's BigTable. It uses HDFS for persistence, which
is a huge benefit if a key requirement of your NoSQL system is the ability to read and write data into HBase using
MapReduce.

* HBase project page: [http://hbase.apache.org/](http://hbase.apache.org/) and mailing lists: [http://hbase.apache.org/mail-lists.html](http://hbase.apache.org/mail-lists.html)
* A good presentation by Amandeep Khurana on HBase: [http://www.slideshare.net/amansk/hbase-hadoop-day-seattle-4987041](http://www.slideshare.net/amansk/hbase-hadoop-day-seattle-4987041)
* HBase wiki: [http://wiki.apache.org/hadoop/Hbase](http://wiki.apache.org/hadoop/Hbase)
* The HBase Reference Guide - a great resource on how HBase's data model, design and configuration: [http://hbase.apache.org/book.html](http://hbase.apache.org/book.html)
* HBase in Action, a book from Manning: [http://www.manning.com/dimidukkhurana/](http://www.manning.com/dimidukkhurana/)

## HBase on YARN (Hoya)

Hoya is a YARN application that allows multiple HBase clusters to coexist on a single Hadoop YARN cluster.
This provides strong data/resource isolation properties, in conjunction with the ability to easily spin up,
upsize/downsize and shutdown HBase clusters. Hoya was developed by Steve Loghran and friends over at Hortonworks.

* GitHub project: [https://github.com/hortonworks/hoya/](https://github.com/hortonworks/hoya/)
* Introducing Hoya: [http://hortonworks.com/blog/introducing-hoya-hbase-on-yarn/](http://hortonworks.com/blog/introducing-hoya-hbase-on-yarn/)
* Hoya architecture: [http://hortonworks.com/blog/hoya-hbase-on-yarn-application-architecture/](http://hortonworks.com/blog/hoya-hbase-on-yarn-application-architecture/)
* Presentation by Steve and Devaraj: [http://www.slideshare.net/steve_l/hoya-hbase-on-yarn-20130820-hbase-hug](http://www.slideshare.net/steve_l/hoya-hbase-on-yarn-20130820-hbase-hug)

## Apache Accumulo

Accumulo is a BigTable implementation much like HBase. It also uses HDFS for storage, and currently has an edge in the
security world due to its cell-level security. Although it should be noted that this is planned for HBase
(see [HBASE-6222](https://issues.apache.org/jira/browse/hbase-6222)).

* Project page: [http://accumulo.apache.org/](http://accumulo.apache.org/)
* Todd Lipcon's presentation comparing HBase and Accumulo [http://www.slideshare.net/cloudera/h-base-and-accumulo-todd-lipcom-jan-25-2012](http://www.slideshare.net/cloudera/h-base-and-accumulo-todd-lipcom-jan-25-2012)

## ElephantDB

ElephantDB is a read-only key-value store, which uses HDFS to load data which is served in real-time. It's a part of
Nathan Marz's Lambda Architecture and enables the rapid loading and serving of data produced in the batch tier.

* GitHub page: [https://github.com/nathanmarz/elephantdb](https://github.com/nathanmarz/elephantdb)
* Presentation by Nathan Marz: [http://www.slideshare.net/nathanmarz/elephantdb](http://www.slideshare.net/nathanmarz/elephantdb)
* Presentation by Soren Macbeth, a contributor to the project: [https://speakerdeck.com/sorenmacbeth/introduction-to-elephantdb](https://speakerdeck.com/sorenmacbeth/introduction-to-elephantdb)

## Storm

Storm is a stream processing, continuous computation and distributed RPC system developed and open-sourced by Twitter.
It allows you to perform near real-time calculations such as trending topics.

* Project home: [http://storm-project.net/](http://storm-project.net/)
* GitHub project: [https://github.com/nathanmarz/storm](https://github.com/nathanmarz/storm)
* Extensive documentation which covers the background and basics on how Storm works: [https://github.com/nathanmarz/storm/wiki](https://github.com/nathanmarz/storm/wiki)
* Natan Marz presentation on Storm: [http://www.youtube.com/watch?v=bdps8tE0gYo](http://www.youtube.com/watch?v=bdps8tE0gYo)
* Running a multi-node Storm cluster from Michael Noll: [http://www.michael-noll.com/tutorials/running-multi-node-storm-cluster/](http://www.michael-noll.com/tutorials/running-multi-node-storm-cluster/)
* Understanding the parallelism of a Storm topology, also from Mr. Noll: [http://www.michael-noll.com/blog/2012/10/16/understanding-the-parallelism-of-a-storm-topology/](http://www.michael-noll.com/blog/2012/10/16/understanding-the-parallelism-of-a-storm-topology/)

## Storm on YARN

Yahoo use Storm for a variety of use cases, and created the Storm-on-YARN so that then could run Storm on their YARN
clusters. They also added the ability for Storm to read/write to secure HDFS.

* GitHub project page: [https://github.com/yahoo/storm-yarn](https://github.com/yahoo/storm-yarn)
* Yahoo! blog post introducing the project: [http://developer.yahoo.com/blogs/ydn/storm-yarn-released-open-source-143745133.html](http://developer.yahoo.com/blogs/ydn/storm-yarn-released-open-source-143745133.html)
* Hortonworks blog on the project: [http://hortonworks.com/blog/streaming-in-hadoop-yahoo-release-storm-yarn/](http://hortonworks.com/blog/streaming-in-hadoop-yahoo-release-storm-yarn/)
* Hadoop Summit 2013 presentation: [http://www.slideshare.net/Hadoop_Summit/feng-june26-1120amhall1v2](http://www.slideshare.net/Hadoop_Summit/feng-june26-1120amhall1v2)

## Apache Samza

Samza (incubating) is a stream processing system that uses Kafka for messaging, and optionally YARN for resource management.

* Project page: [http://samza.incubator.apache.org/](http://samza.incubator.apache.org/)
* LinkedIn post on Samza's background: [http://engineering.linkedin.com/data-streams/apache-samza-linkedins-real-time-stream-processing-framework](http://engineering.linkedin.com/data-streams/apache-samza-linkedins-real-time-stream-processing-framework)

## Morphlines

Morphlines is a ETL library from Cloudera that has implementations available for use within Flume, MapReduce and HBase.
Using a modified JSON syntax it allows you to create a pipeline of work which can fulfill use cases such as near real-time
writes from Flume into Solr Cloud.

* GitHub page: [https://github.com/cloudera/search](https://github.com/cloudera/search)
* Introductory blog post: [http://blog.cloudera.com/blog/2013/07/morphlines-the-easy-way-to-build-and-integrate-etl-apps-for-apache-hadoop/](http://blog.cloudera.com/blog/2013/07/morphlines-the-easy-way-to-build-and-integrate-etl-apps-for-apache-hadoop/)
* Presentation from Cloudera: [http://www.slideshare.net/cloudera/using-morphlines-for-onthefly-etl](http://www.slideshare.net/cloudera/using-morphlines-for-onthefly-etl)
* Documentation as part of the Cloudera Development Kit: [http://cloudera.github.io/cdk/docs/0.5.0/cdk-morphlines/index.html](http://cloudera.github.io/cdk/docs/0.5.0/cdk-morphlines/index.html)

## Apache Giraph

Giraph is a framework for performing offline batch processing of semi-structured graph data on a massive scale. It
offers performance advantages over graph processing with MapReduce.

* Project page: [http://giraph.apache.org/](http://giraph.apache.org/)
* Quick start guide: [http://giraph.apache.org/quick_start.html](http://giraph.apache.org/quick_start.html)
* HadoopSummit 2013 presentation: [http://www.youtube.com/watch?v=_RsJfZGQo9I](http://www.youtube.com/watch?v=_RsJfZGQo9I)
* Architectural overview: [http://www.slideshare.net/averyching/20111014hortonworks](http://www.slideshare.net/averyching/20111014hortonworks)

## Impala

Impala from Cloudera is an implementation of Google's paper on [Dremel](http://research.google.com/pubs/pub36632.html), and provides
interactive SQL capabilities on top of data in HDFS and HBase.

* GitHub page: [https://github.com/cloudera/impala](https://github.com/cloudera/impala)
* Project announcement from Cloudera: [http://blog.cloudera.com/blog/2012/10/cloudera-impala-real-time-queries-in-apache-hadoop-for-real/](http://blog.cloudera.com/blog/2012/10/cloudera-impala-real-time-queries-in-apache-hadoop-for-real/)
* Impala 1.0 release announcement: [http://blog.cloudera.com/blog/2013/05/cloudera-impala-1-0-its-here-its-real-its-already-the-standard-for-sql-on-hadoop/](http://blog.cloudera.com/blog/2013/05/cloudera-impala-1-0-its-here-its-real-its-already-the-standard-for-sql-on-hadoop/)
* Configuring Impala for multi-tenant performance: [http://blog.cloudera.com/blog/2013/06/configuring-impala-and-mapreduce-for-multi-tenant-performance/](http://blog.cloudera.com/blog/2013/06/configuring-impala-and-mapreduce-for-multi-tenant-performance/)
* Cloudera presentation at the Swiss Big Data User Group: [http://www.slideshare.net/SwissHUG/cloudera-impala-15376625](http://www.slideshare.net/SwissHUG/cloudera-impala-15376625)

## Apache Drill

An (incubating) project that offers the promise of interactive SQL capabilities over data in HDFS, HBase, Cassandra,
MongoDB and Splunk.

* Apache incubating project page: [http://incubator.apache.org/drill/](http://incubator.apache.org/drill/)
* Architecture outlines: [http://www.slideshare.net/jasonfrantz/drill-architecture-20120913](http://www.slideshare.net/jasonfrantz/drill-architecture-20120913)

## Parquet

Parquet, a joint initiative from Cloudera and Twitter, is a columnar data format supporting nested data. It can offer space and time advantages over row-ordered data,
especially with queries that return a subset of the overall columns. It supports a wide variety of tools (MapReduce,
Impala, Pig and Hive) and is used in production by Twitter.

* GitHub page: [https://github.com/Parquet](https://github.com/Parquet)
* Presentation from Cloudera Impala meetup: [http://www.slideshare.net/cloudera/presentations-25757981](http://www.slideshare.net/cloudera/presentations-25757981)
* Hadoop Summit 2013 presentation: [http://www.youtube.com/watch?v=pFS-FScophU](http://www.youtube.com/watch?v=pFS-FScophU) and accompanying slides [http://www.slideshare.net/julienledem/parquet-hadoop-summit-2013](http://www.slideshare.net/julienledem/parquet-hadoop-summit-2013)
* Twitter blog post: [https://blog.twitter.com/2013/dremel-made-simple-with-parquet](https://blog.twitter.com/2013/dremel-made-simple-with-parquet)
* Cloudera blog post: [http://blog.cloudera.com/blog/2013/03/introducing-parquet-columnar-storage-for-apache-hadoop/](http://blog.cloudera.com/blog/2013/03/introducing-parquet-columnar-storage-for-apache-hadoop/)

## ORC File

ORC File is a columnar data format that also supports nested data. It is currently implemented within Hive 0.11.

* Presentation from Hortonworks: [http://www.slideshare.net/oom65/orc-files](http://www.slideshare.net/oom65/orc-files)
* Details on the file format: [https://cwiki.apache.org/Hive/languagemanual-orc.html](https://cwiki.apache.org/Hive/languagemanual-orc.html)
* Hadoop Summit 2013 presentation [http://www.youtube.com/watch?v=GV7vpR7vpjM](http://www.youtube.com/watch?v=GV7vpR7vpjM) and slides [http://www.slideshare.net/oom65/orc-andvectorizationhadoopsummit](http://www.slideshare.net/oom65/orc-andvectorizationhadoopsummit)

## Apache Tez

Tez (incubating) is a generalized DAG execution engine. The goal of the project is to remove disk barriers that exist with pipelined
MapReduce jobs. The first goal of the project is to provide a MapReduce implementation using Tez, followed by Hive and
Pig.

* Incubating page at Apache: [http://incubator.apache.org/projects/tez.html](http://incubator.apache.org/projects/tez.html)
* Introducing Tez: [http://hortonworks.com/blog/introducing-tez-faster-hadoop-processing/](http://hortonworks.com/blog/introducing-tez-faster-hadoop-processing/)
* Hadoop Summit 2013 presentation [http://www.youtube.com/watch?v=9ZLLzlsz7h8](http://www.youtube.com/watch?v=9ZLLzlsz7h8) and accompanying slides [http://www.slideshare.net/Hadoop_Summit/murhty-saha-june26255pmroom212](http://www.slideshare.net/Hadoop_Summit/murhty-saha-june26255pmroom212)

## Apache Mesos

Mesos is a cluster manager, similar to YARN, providing resource sharing and isolation capabilities in a distributed
cluster. It can support multiple instances and versions of Hadoop, Spark and other applications. It's used in Twitter to
manage various applications in production.

* Project page: [http://mesos.apache.org/](http://mesos.apache.org/)
* Tech talk: [http://www.youtube.com/watch?v=Hal00g8o1iY](http://www.youtube.com/watch?v=Hal00g8o1iY)

## Lambda Architecture

The Lambda Architecture, an architectural blueprint from Nathan Marz, suggests that speed and batch layers should exist
to play to their mutual strengths: the speed layer providing near real-time data aggregations, and the batch layer providing
a mechanism to correct potential mistakes made in the speed layer.

* Nathan's book, Big Data from Manning, which goes into detail on the Lambda Architecture: [http://www.manning.com/marz/](http://www.manning.com/marz/)
* Nathan's presentation explaining the background behind Lambda: [http://www.slideshare.net/nathanmarz/runaway-complexity-in-big-data-and-a-plan-to-stop-it](http://www.slideshare.net/nathanmarz/runaway-complexity-in-big-data-and-a-plan-to-stop-it)

## Summingbird

Summingbird is a project out of Twitter which could be viewed as an implementation of the Lambda Architecture. It allows
you to using a single API to define operations on distributed collections which can be mapped into MapReduce or Storm
executions.

* GitHub project page: [https://github.com/twitter/summingbird](https://github.com/twitter/summingbird)
* Twitter blog post on Summingbird: [https://blog.twitter.com/2013/streaming-mapreduce-with-summingbird](https://blog.twitter.com/2013/streaming-mapreduce-with-summingbird)
* Sam Ritchie presentation on Summingbird: [http://www.youtube.com/watch?v=Y3PETLJeP7o](http://www.youtube.com/watch?v=Y3PETLJeP7o) and accompanying slides [https://speakerdeck.com/sritchie/summingbird-streaming-mapreduce-at-twitter](https://speakerdeck.com/sritchie/summingbird-streaming-mapreduce-at-twitter)

## Apache Spark

Spark (incubating) is an in-memory distributed processing system which allows you to perform MapReduce, as well as iterative
workloads over data. Spark and its family of associated projects (such as Spark Streaming, GraphX) offers a complete
solution to most distributed processing use cases.

* Project page: [http://spark.incubator.apache.org/](http://spark.incubator.apache.org/)
* Documentation, including links to video tutorials: [http://spark.incubator.apache.org/documentation.html](http://spark.incubator.apache.org/documentation.html)



The example that refers to HADOOP_CLASSPATH is using it in the context of a local JAR. In the last example in the blog, both HADOOP_CLASSPATH and LIBJARS are referring to JAR's on the local filesystem. The JAR's in HADOOP_CLASSPATH are only used by the client-side of MapReduce (i.e. your driver code), and the LIBJARS is used to copy the JAR's into HDFS for use by the map and reduce processes in Hadoop.