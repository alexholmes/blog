---
layout: post
title: Hadoop unit testing with MiniMRCluster and MiniDFSCluster
date: 2012-10-20 00:20:00 -05:00
categories:
  -- hadoop
---

In a [recent blog post](http://steveloughran.blogspot.com/2012/10/hadoop-in-practice-applied-hadoop.html)
Steve Loughran mentioned that I didn't cover Hadoop's [MiniMRCluster](http://svn.apache.org/viewvc/hadoop/common/tags/release-1.0.3/src/test/org/apache/hadoop/mapred/MiniMRCluster.java?view=co)
in my book. At the time I wrote the testing chapter of *"Hadoop in Practice"*
I decided that covering
[MRUnit](http://mrunit.apache.org/) and [LocalJobRunner](http://svn.apache.org/viewvc/hadoop/common/tags/release-1.0.3/src/mapred/org/apache/hadoop/mapred/LocalJobRunner.java?view=co)
were sufficient to cover the goals of most MapReduce unit test, but for completeness I want to
cover MiniMRCluster in this post.

MRUnit is great for quick and easy unit testing of MapReduce jobs, where you don't want to test
Input/OutputFormat and Partitioner code. LocalJobRunner is a step above MRUnit in that it allows you
to test Input/OutputFormat classes, but it is single-threaded so it's not useful
for uncovering bugs related to multiple map or reduce tasks, or for properly exercising partitioners.

That's where  [MiniMRCluster](http://svn.apache.org/viewvc/hadoop/common/tags/release-1.0.3/src/test/org/apache/hadoop/mapred/MiniMRCluster.java?view=co)
(and [MiniDFSCluster](http://svn.apache.org/viewvc/hadoop/common/tags/release-1.0.3/src/test/org/apache/hadoop/hdfs/MiniDFSCluster.java?view=co))
come into play. These classes offer full-blown in-memory MapReduce and HDFS clusters, and can launch
multiple MapReduce and HDFS nodes. MiniMRCluster and MiniDFSCluster are bundled with the Hadoop 1.x test JAR, and are used heavily within
Hadoop's own unit tests.

The easy way to leverage MiniMRCluster and MiniDFSCluster is to extend the
abstract [ClusterMapReduceTestCase](http://svn.apache.org/viewvc/hadoop/common/tags/release-1.0.3/src/test/org/apache/hadoop/mapred/ClusterMapReduceTestCase.java?view=co)
class, which is a JUnit `TestCase` and starts/stops a Hadoop cluster around each JUnit test.
ClusterMapReduceTestCase runs a 2-node MapReduce cluster with
2 HDFS nodes. The way you should be able to use this class is as follows:

    public class IdentityTest extends ClusterMapReduceTestCase {
        public void test() throws Exception {
            JobConf conf = createJobConf();

            Path inDir = new Path("testing/jobconf/input");
            Path outDir = new Path("testing/jobconf/output");

            OutputStream os = getFileSystem().create(new Path(inDir, "text.txt"));
            Writer wr = new OutputStreamWriter(os);
            wr.write("b a\n");
            wr.close();

            conf.setJobName("mr");

            conf.setOutputKeyClass(Text.class);
            conf.setOutputValueClass(LongWritable.class);

            conf.setMapperClass(WordCountMapper.class);
            conf.setReducerClass(SumReducer.class);

            FileInputFormat.setInputPaths(conf, inDir);
            FileOutputFormat.setOutputPath(conf, outDir);

            assertTrue(JobClient.runJob(conf).isSuccessful());

            // Check the output is as expected
            Path[] outputFiles = FileUtil.stat2Paths(
                    getFileSystem().listStatus(outDir, new Utils.OutputFileUtils.OutputFilesFilter()));

            assertEquals(1, outputFiles.length);

            InputStream in = getFileSystem().open(outputFiles[0]);
            BufferedReader reader = new BufferedReader(new InputStreamReader(in));
            assertEquals("a\t1", reader.readLine());
            assertEquals("b\t1", reader.readLine());
            assertNull(reader.readLine());
            reader.close();
        }
    }

However, at least with the Hadoop 1.0.3 release, this will fail with the following exception:

    12/10/19 23:10:37 ERROR mapred.MiniMRCluster: Job tracker crashed
    java.lang.NullPointerException
      at java.io.File.<init>(File.java:222)
      at org.apache.hadoop.mapred.JobHistory.initLogDir(JobHistory.java:531)
      at org.apache.hadoop.mapred.JobHistory.init(JobHistory.java:499)
      at org.apache.hadoop.mapred.JobTracker$2.run(JobTracker.java:2334)
      at org.apache.hadoop.mapred.JobTracker$2.run(JobTracker.java:2331)
      at java.security.AccessController.doPrivileged(Native Method)
      ...

The trick here is that the JobTracker is expecting `hadoop.log.dir` to be set in the system properties, which it isn't
in our example, causing the NPE. As it turns out this is a bug (see [MAPREDUCE-2785](https://issues.apache.org/jira/browse/MAPREDUCE-2785))
which according to Jira will be fixed in the Hadoop 1.1 release (thanks to Steve for that information).
The fix is simple - override the `setUp()` method in ClusterMapReduceTestCase
and set the Hadoop log directory:

    @Override
    protected void setUp() throws Exception {

        System.setProperty("hadoop.log.dir", "/tmp/logs");

        super.startCluster(true, null);
    }

Once you make this change the above JUnit test will work. This can be a bit tedious to have to roll
into each and every one of your unit tests, but luckily there are a couple of options out there so
that you don't have to.

First, Steve pointed out a [LocalMRCluster](http://smartfrog.svn.sourceforge.net/viewvc/smartfrog/trunk/core/hadoop-components/grumpy/src/org/smartfrog/services/hadoop/grumpy/LocalMRCluster.groovy)
Groovy class bundled in [SmartFrog](http://wiki.smartfrog.org/wiki/display/sf/SmartFrog+Home) which
fixes this issue by extending MiniMRCluster.

Another alternative is to use my GitHub [hadoop-utils](https://github.com/alexholmes/hadoop-utils) project
which contains a JUnit class similar to ClusterMapReduceTestCase
called [MiniHadoopTestCase](https://github.com/alexholmes/hadoop-utils/blob/master/src/main/java/com/alexholmes/hadooputils/test/MiniHadoopTestCase.java)
which fixes this property problem, and also gives you more control over where the in-memory clusters
will store their data on your local filesystem, and also let you control the number of TaskTrackers
and DataNodes.

Hadoop-utils also contains a helper class (TextIOJobBuilder) to help with writing MapReduce input files, and verifying the
output results.  You can see an example of how clean your unit tests can look when combining TextIOJobBuilder with MiniHadoopTestCase
in class [TotalOrderSortTest](https://github.com/alexholmes/hadoop-utils/blob/master/src/test/java/com/alexholmes/hadooputils/sort/TotalOrderSortTest.java):

    public class TotalOrderSortTest extends MiniHadoopTestCase {

        @Test
        public void test() throws Exception {

            InputSampler.RandomSampler sampler = new InputSampler.RandomSampler(1.0, 6, 1);

            JobConf jobConf = super.getMiniHadoop().createJobConf();

            TextIOJobBuilder builder = new TextIOJobBuilder(
                    super.getMiniHadoop().getFileSystem())
                    .addInput("foo-hump")
                    .addInput("foo-hump")
                    .addInput("clump-bar")
                    .addExpectedOutput("clump-bar")
                    .addExpectedOutput("foo-hump")
                    .writeInputs();

            new SortConfig(jobConf).setUnique(true);

            SortTest.run(
                    jobConf,
                    builder,
                    2,
                    2,
                    sampler);
        }
    }

The only real downside to using MiniMRCluster and MiniDFSCluster is speed - it takes a good 5-10 seconds
for both setup and tear-down, and when you multiply this for each test case this can add up.
