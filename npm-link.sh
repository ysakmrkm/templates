#!/bin/sh

if [ $# -eq 0 ]; then

for i in `cat package.json | jq '.devDependencies | keys | .[]'`;
do
`echo npm link $i | sed -e 's/"//g'`;
done

elif [ $# -eq 1 ]; then

`echo npm install $1 --save-dev`;
`echo npm install -g $1`;
`echo npm uninstall $1`;
`echo npm link $1`;

else

exit 1

fi
