#!/bin/sh

if [ $# -eq 0 ]; then
  echo "Need path that files are exist.";

  exit 1
else
  shopt -s dotglob

  files=`find ${1%/}/conf/ln -maxdepth 1 -type f`

  for filepath in $files; do
    `echo ln -fs $filepath ./`;
  done

  files="${1%/}/conf/ln/usr/*"

  for filepath in $files; do
    `echo ln -fs $filepath ~/`;
  done

  files="${1%/}/conf/ln/project/*"

  for filepath in $files; do
    `echo ln -fs $filepath ./`;
  done

  shopt -u dotglob

  `echo cp -r ${1%/}/conf/cp/. ./`;

  echo "Finish config files copy.";

fi
