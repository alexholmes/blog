---
layout: post
title: Using Hadoop 2.2 as a sink in Flume 1.4
quote: Working around the protobuf 2.5 dependency introduced by Hadoop 2.2.
date: 2014-02-09 09:20:00 -05:00
categories:
  -- hadoop
---

Google really screwed the pooch with their protobuf 2.5 release. Code generated with protobuf 2.5 is
binary incompatible with protobuf 2.4 and older libraries.  Unfortunately the current stable release
of Flume 1.4 packages protobuf 2.4.1 and if you try and use Hadoop 2.2 as a sink you'll be smacked
with the following exception:

    java.lang.VerifyError: class org.apache.hadoop.security.proto.SecurityProtos$GetDelegationTokenRequestProto
    overrides final method getUnknownFields.()Lcom/google/protobuf/UnknownFieldSet;
        at java.lang.ClassLoader.defineClass1(Native Method)
        at java.lang.ClassLoader.defineClassCond(ClassLoader.java:631)
        ...
        at org.apache.hadoop.ipc.ProtobufRpcEngine.getProxy(ProtobufRpcEngine.java:92)
        at org.apache.hadoop.ipc.RPC.getProtocolProxy(RPC.java:537)
        at org.apache.hadoop.hdfs.NameNodeProxies.createNNProxyWithClientProtocol(NameNodeProxies.java:328)
        at org.apache.hadoop.hdfs.NameNodeProxies.createNonHAProxy(NameNodeProxies.java:235)

Hadoop 2.2 uses protobuf 2.5.0 for its RPC, and Flume loads its own packaged version of protobuf ahead of Hadoop's,
which causes this error. To fix this you'll need to move both protobuf and guava out of Flume's lib directory.
The following command moves them into your home directory.

    $ mv ${flume_bin}/lib/{protobuf-java-2.4.1.jar,guava-10.0.1.jar} ~/

Now if you restart your Flume agent you'll be able to target HDFS as a sink with Hadoop 2.2. Great success!
