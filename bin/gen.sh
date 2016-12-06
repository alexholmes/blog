#!/bin/bash

# This script should be under /app/blog/gen.sh

send_email_and_exit() {
  recipient=$1
  message=$2

  echo "Sending email and exiting due to error"

  /bin/mail -s "Blog generation failure" "${recipient}" << EOF
${message}
EOF

  exit 1
}

echo "Running at "`date`

basedir=/app/blog
gitdir=${basedir}/blog
nginxdir=/usr/share/nginx/html
githubrepo=https://github.com/alexholmes/blog.git
emailto="grep.alex@gmail.com"

if [ ! -d ${gitdir} ]; then
  echo "Checking out repo for the first time"
  mkdir -p ${gitdir}
  cd ${basedir}
  git clone ${githubrepo}
else
  cd ${gitdir}
  git pull
fi

cd ${gitdir}

rm -rf ${nginxdir}/*
jekyll --no-auto . ${nginxdir}/

exitCode=$?

if [ ${exitCode} != "0" ]; then
  send_email_and_exit "${emailto}" "Jekyll failed with exit code ${exitCode}"
fi

curl http://0.0.0.0:80/ >/dev/null 2>&1

exitCode=$?

if [ ${exitCode} != "0" ]; then
  send_email_and_exit "${emailto}" "Curl failed with exit code ${exitCode}"
fi
