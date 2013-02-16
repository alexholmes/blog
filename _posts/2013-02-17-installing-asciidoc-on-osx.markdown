---
layout: post
title: Installing AsciiDoc on OSX
date: 2013-02-17 09:00:00 -05:00
categories:
  -- OSX
---

[AsciiDoc](http://asciidoc.org/) is a markup language and tool that I'm starting to play with to
produce DocBook and PDF/HTML versions of my work. It took me a little longer than expected to
get it up and running, so hopefully this blog will serve as a quick install guide for you,
as well as the future me.

First I had to install [Homebrew](http://mxcl.github.com/homebrew/), a useful package manager
fo OSX:

{% highlight bash %}
$ sudo mkdir /usr/local/homebrew
$ cd /usr/local/homebrew
$ sudo curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C .
$ sudo ln -s `pwd`/bin/brew /usr/local/bin/brew
{% endhighlight %}

Next-up was installing AsciiDoc and other required libraries via `brew`:

{% highlight bash %}
$ sudo brew install autoconf automake libevent asciidoc
{% endhighlight %}

After this I had to update my bash profile file to set an environment variable that points to
the XML catalog created as part of the AsciiDoc installation:

{% highlight bash %}
$ echo "export XML_CATALOG_FILES=/usr/local/etc/xml/catalog" >>  ~/.bash_profile
{% endhighlight %}

Now you have to [download Apache FOP](http://xmlgraphics.apache.org/fop/download.html), a print
formatter used by AsciiDoc to create PDF's, which in
my case resulted in a file at `~/Downloads/fop-1.0-bin.tar.gz`. Untar the contents and create a
symbollic link for `fop`:

{% highlight bash %}
$ cd /usr/local/
$ sudo tar -xzvf ~/Downloads/fop-1.0-bin.tar.gz
$ sudo ln -s /usr/local/fop-1.0/fop /usr/bin/fop
{% endhighlight %}

Finally, let's make sure that everything is installed correctly. Create a sample AsciiDoc file
called `sample.asciidoc` with the following contents:

    Your First AsciiDoc
    ===================
    Jane Blogs
    :Author Initials: JB

    This is your first AsciiDoc file - yay for you!

You can then run `a2x`, which will first generate
a DocBook version of your AsciiDoc file, and then goes on to generate the PDF.

{% highlight bash %}
$ a2x -v -fpdf -dbook --fop sample.asciidoc
{% endhighlight %}

This should create a sample.pdf in the same directory as your AsciiDoc file.
You can also generate a HTML version with:

{% highlight bash %}
$ asciidoc -b html5 -a data-uri -a toc2 tada.asciidoc
{% endhighlight %}


