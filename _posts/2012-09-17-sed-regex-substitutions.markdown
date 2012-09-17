---
layout: post
title: Using sed to perform inline replacements of regex groups
date: 2012-09-17 00:20:00 -05:00
categories:
  -- *nix
---

I love tools like sed and awk - I use them every day, and only realize how much I rely on them
when I'm forced to work on a machine that's not running Unix.  Today I want to look at a feature
that is really useful when working with regular expressions in sed.

Imagine that you had an IP address, and you wanted to change the second octet - one way to do this
in sed is the following:

    shell$ echo "127.0.0.1" | sed "s/127.0/127.1/"
    127.1.0.1

That seemed to work well, and was simple. But what if you had a file of random IP's - how
would you change the second octet
in that scenario? Sure, you could use awk, but that feels like it would be overkill.
Well, it can be done in sed with something called regular expression group substitutions.

First of all, you'll need to tell sed that you are using extended regular expressions
by using the `-r` option, so that you don't have to escape some of the regular expression characters
(if you're curious, they are `?+(){}`).
If you end up needing to use any of these characters as literals, you'll ned to escape them with a
backslash (`\`).

sed supports up to 9 groups that can be defined in the pattern string, and subsequently referenced in
the replacement string.  In the following command the pattern string starts with a group,
which contains the first octet followed by the period, and that's followed by a second octet.
In the replacement string we're referencing the first (and only)
group with `\1`, followed by `234` which is the replacement for the rest of the matching string,
which contains the second octet.

    shell$ echo "127.0.0.1" | sed -r "s/^([0-9]{1,3}\.)[0-9]{1,3}/\1234/"
    127.234.0.1

What if we wanted to preserve the second octet and simply a "1" in front of it? In that case you can
 define a second group in the pattern, and reference the second group in the replacement value:

    shell$ echo "127.0.0.1" | sed -r "s/^([0-9]{1,3}\.)([0-9]{1,3})/\11\2/"
    127.10.0.1

Actually it would have been easier to just remove the second octet altogether from the pattern:

    shell$ echo "127.0.0.1" | sed -r "s/^([0-9]{1,3}\.)/\11/"
    127.10.0.1

On a final note - it wasn't so long ago that I would write a command similar to the one below
if I wanted to use sed to perform a substitution and overwrite an existing file:

    shell$ sed 's/a/b/' file1.txt > file2.txt; mv file2.txt file1.txt

Ugh! Well there's no need to do this - sed has a `-i` option which will do an inline replace of
the file:

    shell$ sed 's/a/b/' file1.txt

Ahhh, that's better!  Anything that's easy on the eyes gets a thumbs-up from me.
