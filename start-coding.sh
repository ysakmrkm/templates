#!/bin/sh

if [ $# -eq 0 ]; then
  echo "Need path that files are exist.";

  exit 1
else
  `echo init-config $1`;
  `echo npm-link`;
  `echo copy-source $1`;
  `echo git init`;
  `echo git-flow init`;
  `echo npm start`;

  echo "You can start coding.";
fi
