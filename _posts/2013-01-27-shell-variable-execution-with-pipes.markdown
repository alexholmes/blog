---
layout: post
title: Executing variables that contain shell operators
date: 2013-01-27 17:20:00 -05:00
categories:
  -- *nix
---

I touched a little on [pipes](/2012/10/29/useless-cats/) in a previous post.
Here's a quick example of an `echo` utility which outputs two lines, and a pipe operator
which redirects that output to a `grep` utility which performs a simple filter to only include
lines that contain the word "cat":

    shell$ echo -e 'the cat \n sat on the mat' | grep cat
    the cat

Cool - since that worked, what do you think will happen if you do the following?

    shell$ cmd="echo -e 'the cat \n sat on the mat' | grep cat"
    shell$ ${cmd}

In the above example we're simply assigning the original utility to a
shell variable, and then executing it. So why, then, would the output be this?

    shell$ ${cmd}
    'the cat
     sat on the mat' | grep cat

This is something that has bitten me in the past when I write shell scripts. What's happening
here is that the shall executes the contents of variable `cmd` as a single utility, so
the shell passes everything after `echo` as arguments to echo utility, including the pipe.

![variable-execution](/images/variable-execution.png)

What we actually need to happen is to have the contents of `cmd` evaluated by the shell so that
the shell can create the pipeline between the two utilities. This is where the utility
[eval](http://www.unix.com/man-page/posix/1posix/eval/)
comes into play - `eval` tells the shell to concatenate the arguments and have them executed
by the shell.

    shell$ eval ${cmd}
    the cat

The morale of this story is that if you want to execute a variable that includes any shell operators
(such as the pipe in our example) - then make sure you `eval`.
