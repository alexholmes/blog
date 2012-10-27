---
layout: post
title: Using vmstat to understand process performance on Linux
date: 2012-10-27 00:20:00 -05:00
categories:
  -- *nix
---

[vmstat](http://unixhelp.ed.ac.uk/CGI/man-cgi?vmstat) is a great tool for diagnosing performance
problems in Linux.  The typical relationship I have with vmstat is as follows:

    $ vmstat <args>
    ...

    $ man vmstat

    $ chrome  (Google search for "vmstat output")

As you can see what ends up happening is that I rely on `man` combined with Internet searches to expand on the
terse details in the vmstat manual.

After repeating this cycle more times than I care to remember, I decided to draw an annotated
figure to help the future Alex be more effective. The figure below is the result of that work,
which shows the process-related aspects of the vmstat output.

![parition](/images/vmstat-cpu.png)

