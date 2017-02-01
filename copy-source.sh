#!/bin/sh

if [ $# -eq 0 ]; then
  echo "Need path that files are exist.";

  exit 1
else
  `echo mkdir -p ./src`;
  `echo cp -r ${1%/}/jade ./src`;
  `echo cp -r ${1%/}/sass ./src`;
  `echo cp -r ${1%/}/fonts ./src`;
  `echo cp -r ${1%/}/cs ./src`;

  echo "Finish copy source files.";
fi
