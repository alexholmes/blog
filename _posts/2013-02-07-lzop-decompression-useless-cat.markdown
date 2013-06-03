---
layout: post
title: LZOP decompression - revenge of the useless cat
quote: The nuances of using the lzop CLI to view the contents of LZOP files.
date: 2013-02-08 09:00:00 -05:00
categories:
  -- *nix
---

For me LZOP is the ubiquitous compression codec with working with large text files in HDFS due to
its MapReduce data locality advantages. As a result when I want to peek at LZOP-compressed files in
HDFS I use a command such as:

{% highlight bash %}
shell$ hadoop fs -get /some/file.lzo | lzop -dc | head
{% endhighlight %}

With this command the output of a LZOP-compressed file in HDFS is piped to the `lzop` utility,
where the `-dc` flags tell lzop to decompress the stream and write the uncompressed data to
standard out, and the final `head` will show the first 10 lines of the data.  I may substitute
`head` with other utilities such as `awk` or `sed`, but I always follow this general pattern of
piping the output `lzop` output to another utility.

Imagine my surprise the other day when I tried the same command on a smaller file (hence not
needing to use the `head` command), only to see this error:

{% highlight bash %}
shell$ hadoop fs -get /some/file.lzo | lzop -dc
lzop: <stdout>: uncompressed data not written to a terminal
{% endhighlight %}

What just happened - why would the first command work, but not the second?  My guess is that
this is likely the authors of the `lzop` utility safeguarding us accidentally flooding standard
output with uncompressed data. Which is frustrating, because as you can see from the following
example this is a different route than that which the authors of `gunzip` took:

{% highlight bash %}
shell$ echo "the cat" | gzip -c | gunzip -c
the cat
{% endhighlight %}

If we run the same command with `lzop` we see the same result as was saw earlier:

{% highlight bash %}
shell$ echo "the cat" | lzop -c | lzop -dc
lzop: <stdout>: uncompressed data not written to a terminal
{% endhighlight %}

A ghetto approach to solving this problem is to pipe the `lzop` output to `cat` (which is a
necessary violation of the [useless cat](/2012/10/30/useless-cats/) pattern):

{% highlight bash %}
shell$ hadoop fs -get /some/file.lzo | lzop -dc | cat
{% endhighlight %}

Luckily `lzop` has a `-f` option which removes the need for the `cat`:

{% highlight bash %}
shell$ hadoop fs -get /some/file.lzo | lzop -dcf
{% endhighlight %}

It turns out that `man` page on `lzop` is instructive with regards to the `-f` option, indicates
various scenarios where it can be helpful:

{% highlight bash %}
shell$ man lzop
...
-f, --force
   Force lzop to

    - overwrite existing files
    - (de-)compress from stdin even if it seems a terminal
    - (de-)compress to stdout even if it seems a terminal
    - allow option -c in combination with -U

   Using -f two or more times forces things like

    - compress files that already have a .lzo suffix
    - try to decompress files that do not have a valid suffix
    - try to handle compressed files with unknown header flags

   Use with care.
{% endhighlight %}

