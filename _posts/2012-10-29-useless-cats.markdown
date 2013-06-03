---
layout: post
title: Pipes and useless cats
quote: A post for all you dog lovers about instances of unloved cats in Linux.
date: 2012-10-29 22:20:00 -05:00
categories:
  -- *nix
---

I love me some Unix command [pipes](http://en.wikipedia.org/wiki/Pipeline_(Unix%29):

    $ cat /some/file.txt | sort | head

Pipelines let you chain together multiple commands to manipulate data flows. Pipes are not only
useful as a data filtering mechanism, but when combined with tools such as `cut`, `awk` and `sed`
can also be used for projections and transformations.
The Unix pipe, while simple in concept,
is a sophisticated shell construct and one big reason why Unix shells are to this day a
popular tool in a programmer/system administrator/data scientist's toolkit.

So why am I sitting here telling you something that you already know? Fair question - to answer that
let's take another look at that command:

    $ cat /some/file.txt | sort | head

While shell pipelines are great, we have a subtle problem here - and it's something that's known as
a _useless cat_. No, I don't hate cats - [this expression harks back](http://partmaps.org/era/unix/award.html)
 to the old _usenet_ days where
a forum member of _comp.unix.shell_ would write a weekly post where he would highlight a redundant
use of the `cat` command.

So why is the above command useless? Because `sort` can take one or more files as
arguments, much like the majority of Unix commands. So this command can be rewritten as:

    $ sort /some/file.txt | head

Removing `cat` from the equation means that we've reduced the number of processes that need to
execute, and cut down on the buffering and data copying that the shell needs to do to make pipelines work - a win-win.

In fact `cat` really doesn't have many uses - if you need to view the contents of a file you're
better off using `vi` or `less`, and otherwise most Unix commands can directly work with files.

So next time you're about to run a `cat` command - think about whether or not you need it, or
whether you're just perpetuating use of the _useless cat_!

