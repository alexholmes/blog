---
layout: post
title: Using Avro's code generation from Maven
quote: Avro has a Maven plugin which lets you generate code from Avro schema, IDL and protocol files. This post looks at how to use the plugin and its various options.
date: 2013-05-24 09:20:00 -05:00
categories:
  -- avro
---

[Avro](http://avro.apache.org/) has the ability to generate Java code from Avro schema, IDL and protocol files.
Avro also has a plugin which allows you to generate these Java sources directly from Maven, which is a good idea
as it avoids issues that can arise if your schema/protocol files stray from the checked-in code generated equivalents.

Today I created a simple GitHub project called [avro-maven](https://github.com/alexholmes/avro-maven) because
I had to fiddle a bit to get Avro and Maven to play nice. The GitHub project is self-contained and also has a
README which goes over the basics. In this post I'll go over how to use Maven to generate code for schema, IDL
and protocol files.

# pom.xml updates to support the Avro plugin

Avro schema files only define types, whereas IDL and protocol files model types as well as RPC semantics such as messages.
The only difference between IDL and protocol files is that IDL files are Avro's DSL for specifying RPC, versus
protocol files are the same in JSON form.

Each type of file has an entry that can be used in the `goals` element as can be seen below. All three can be used together,
or if you only have schema files you can safely remove the `protocol` and `idl-protocol` entries (and vice-versa).

{% highlight xml %}
<plugin>
  <groupId>org.apache.avro</groupId>
  <artifactId>avro-maven-plugin</artifactId>
  <version>${avro.version}</version>
  <executions>
    <execution>
      <phase>generate-sources</phase>
      <goals>
        <goal>schema</goal>
        <goal>protocol</goal>
        <goal>idl-protocol</goal>
      </goals>
    </execution>
  </executions>
</plugin>

...

<dependencies>
  <dependency>
    <groupId>org.apache.avro</groupId>
    <artifactId>avro</artifactId>
    <version>${avro.version}</version>
  </dependency>
  <dependency>
    <groupId>org.apache.avro</groupId>
    <artifactId>avro-maven-plugin</artifactId>
    <version>${avro.version}</version>
  </dependency>
  <dependency>
    <groupId>org.apache.avro</groupId>
    <artifactId>avro-compiler</artifactId>
    <version>${avro.version}</version>
  </dependency>
  <dependency>
    <groupId>org.apache.avro</groupId>
    <artifactId>avro-ipc</artifactId>
    <version>${avro.version}</version>
  </dependency>
</dependencies>
{% endhighlight %}

By default the plugin assumes that your Avro sources are located in `${basedir}/src/main/avro`, and that you want
your generated sources to be written to `${project.build.directory}/generated-sources/avro`, where `${project.build.directory}`
is typically the `target` directory.  Keep reading if you want to change any of these settings.

# Avro configurables

Luckily Avro's Maven plugin offers the ability to customize various code generation settings. The following table
shows the configurables that can be used for any of the schema, IDL and protocol code generators.

<table>
    <tr>
        <td><strong>Configurable</strong></td>
        <td><strong>Default value</strong></td>
        <td><strong>Description</strong></td>
    </tr>
    <tr>
        <td>sourceDirectory</td>
        <td>${basedir}/src/main/avro</td>
        <td>The Avro source directory for schema, protocol and IDL files.</td>
    </tr>
    <tr>
        <td>outputDirectory</td>
        <td>${project.build.directory}/generated-sources/avro</td>
        <td>The directory where Avro writes code-generated sources.</td>
    </tr>
    <tr>
        <td>testSourceDirectory</td>
        <td>${basedir}/src/test/avro</td>
        <td>The input directory containing any Avro files used in testing.</td>
    </tr>
    <tr>
        <td>testOutputDirectory</td>
        <td>${project.build.directory}/generated-test-sources/avro</td>
        <td>The output directory where Avro writes code-generated files for your testing purposes.</td>
    </tr>
    <tr>
        <td>fieldVisibility</td>
        <td>PUBLIC_DEPRECATED</td>
        <td>Determines the accessibility of fields (e.g. whether they are public or private).
        Must be one of PUBLIC, PUBLIC_DEPRECATED or PRIVATE. PUBLIC_DEPRECATED merely adds a
        deprecated annotation to each field, e.g. "@Deprecated public long time".</td>
    </tr>
</table>

In addition, the `includes` and `testIncludes` configurables can also be used to specify alternative
file extensions to the defaults, which are `**/*.avsc`, `**/*.avpr` and `**/*.avdl` for schema, protocol and
IDL files respectively.

Let's look at an example of how we can specify all of these options for schema compilation.

{% highlight xml %}
<plugin>
  <groupId>org.apache.avro</groupId>
  <artifactId>avro-maven-plugin</artifactId>
  <version>${avro.version}</version>
  <executions>
    <execution>
      <phase>generate-sources</phase>
      <goals>
        <goal>schema</goal>
      </goals>
      <configuration>
        <sourceDirectory>${project.basedir}/src/main/myavro/</sourceDirectory>
        <outputDirectory>${project.basedir}/src/main/java/</outputDirectory>
        <testSourceDirectory>${project.basedir}/src/main/myavro/</testSourceDirectory>
        <testOutputDirectory>${project.basedir}/src/test/java/</testOutputDirectory>
        <fieldVisibility>PRIVATE</fieldVisibility>
        <includes>
          <include>**/*.avro</include>
        </includes>
        <testIncludes>
          <testInclude>**/*.test</testInclude>
      </testIncludes>
      </configuration>
    </execution>
  </executions>
</plugin>
{% endhighlight %}

As a reminder everything covered in this blog article can be seen in action in the GitHub repo at
[https://github.com/alexholmes/avro-maven](https://github.com/alexholmes/avro-maven).
