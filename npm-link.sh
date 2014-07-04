#!/bin/sh

for i in `cat package.json | jq '.devDependencies | keys | .[]'`;
do
`echo npm install -g $i| sed -e 's/"//g'`;
`echo npm link $i | sed -e 's/"//g'`;
done
