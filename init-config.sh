#!/bin/sh

if [ $# -eq 0 ]; then
  echo "Need path that files are exist.";

  exit 1
else
  `echo ln -fs ${1%/}/.editorconfig ./.editorconfig`;
  `echo ln -fs ${1%/}/.pug-lintrc ./.pug-lintrc`;
  `echo ln -fs ${1%/}/coffeelint.json ./coffeelint.json`;
  `echo ln -fs ${1%/}/scss-lint.yml ./scss-lint.yml`;
  `echo ln -fs ${1%/}/package_gulp.json ./package.json`;
  `echo cp -f ${1%/}/config.rb ./config.rb`;
  `echo cp -f ${1%/}/gulpfile.coffee ./gulpfile.coffee`;

  echo "Finish config files copy.";
fi
