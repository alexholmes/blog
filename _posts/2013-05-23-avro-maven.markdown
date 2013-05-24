---
layout: post
title: Using Avro's code generation from Maven
date: 2013-05-24 09:20:00 -05:00
categories:
  -- avro
---

[Avro](http://avro.apache.org/) has the ability to generate Java beans given an Avro schema file.
Avro also has a plugin which allows you to generate the Java sources from Maven. It's a good idea
 to use your build system to generate sources from your schema, rather than check-in the generated
sources.

Today I create a simple GitHub project called [avro-maven](https://github.com/alexholmes/avro-maven) because
I had to fiddle a bit to get Avro and Maven to play nice. The GitHub project is self-contained and also has a
README which goes over the basics. If you don't feel like moseying over there, here's the Maven
[pom.xml](https://github.com/alexholmes/avro-maven/blob/master/pom.xml) I created:

{% highlight xml %}
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.alexholmes.avro.maven</groupId>
  <artifactId>avro-maven</artifactId>
  <version>0.0.1</version>
  <packaging>jar</packaging>

  <name>Avro Maven Example</name>
  <url>https://github.com/alexholmes/avro-maven</url>

  <properties>
    <jdkLevel>1.6</jdkLevel>
    <requiredMavenVersion>[2.1,)</requiredMavenVersion>
    <main.basedir>${project.basedir}</main.basedir>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.build.outputEncoding>UTF-8</project.build.outputEncoding>
    <maven.compiler>2.0.2</maven.compiler>
    <avro.version>1.7.4</avro.version>
  </properties>

  <description>
    A simple example of how Avro's Maven plugin can be used to compile Avro schema files into Java.
  </description>

  <developers>
    <developer>
      <id>aholmes</id>
      <name>Alex Holmes</name>
      <email>grep.alex@gmail.com</email>
      <url>http://grepalex.com</url>
    </developer>
  </developers>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>2.3.2</version>
        <configuration>
          <source>${jdkLevel}</source>
          <target>${jdkLevel}</target>
          <showDeprecation>true</showDeprecation>
          <showWarnings>true</showWarnings>

        </configuration>
      </plugin>
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
              <sourceDirectory>${project.basedir}/src/main/avro/</sourceDirectory>
              <outputDirectory>${project.basedir}/src/main/java/</outputDirectory>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
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
  </dependencies>
</project>
{% endhighlight %}
