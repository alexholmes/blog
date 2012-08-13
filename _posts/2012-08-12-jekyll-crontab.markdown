---
layout: post
title: Refreshing your blog with jekyll, nginx and cron
date: 2012-08-12 23:56:00 -05:00
categories:
  -- nginx
  -- jekyll
  -- cron
---

This blog is created using the excellent [jekyll](https://github.com/mojombo/jekyll) Ruby-based
HTML generator. Once [nginx](http://nginx.org/) and jekyll have been installed on your *nix system,
and you've pushed your blog to [github](https://github.com/), then all that remains is to create a
shell script which clones your github repo for the first time if it doesn't already exist, or updates
the local copy via the `pull` command:

   shell$ mkdir -p /app/blog
   shell$ vi /app/blog/gen.sh

The contents of your script will be as follows:

    #!/bin/bash

    echo "Running at "`date`

    basedir=/app/blog
    gitdir=${basedir}/blog
    nginxdir=/usr/share/nginx/html
    githubrepo=https://github.com/alexholmes/blog.git

    if [ ! -d ${gitdir} ]; then
      echo "Checking out repo for the first time"
      mkdir -p ${gitdir}
      cd ${basedir}
      git clone ${githubrepo}
    else
      cd ${gitdir}
      git pull
    fi

    rm -rf ${nginxdir}/*
    jekyll --no-auto . ${nginxdir}/

Now all you need is a crontab entry to refresh your blog every 5 minutes:

    shell$ crontab -e
    */5 * * * * /app/blog/gen.sh >& /app/blog/gen.out

To check your crontab settings use the `-l` option:

    shell$ crontab -l
    */5 * * * * /app/blog/gen.sh >& /app/blog/gen.out

You're all set! This is a good alternative to using (GitHub pages)[http://pages.github.com/] if you
wish to host your jekyll site on your own server.