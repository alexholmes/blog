---
layout: post
title: Lexicographically sorting large files in Linux
date: 2012-08-31 20:14:00 -05:00
categories:
  -- *nix
---

When I hear the word "sort" my first thought is "Hadoop"! Yes, sorting is one thing that Hadoop
does well, but if you're working with large files in Linux the built-in sort command is
often all you need.

Let's say you have a large file on a host with 2-4GB of main memory free. The following
[sort](http://www.oreillynet.com/linux/cmd/cmd.csp?path=s/sort) command will result in
[lexicographically](http://en.wikipedia.org/wiki/Lexicographical_order)-ordered output.

    LC_COLLATE=C sort --buffer-size=1G --temporary-directory=./tmp --unique bigfile.txt

Let's break this command down and examine each part in detail.

![sort image](/images/sorting-large-files-linux.png)
