#!/bin/bash



export BASE_PATH=${PWD}

echo $BASE_PATH

cd $BASE_PATH/src/vendor

while read line
do
	git submodule add -f git@github.com:"$line".git
done < $BASE_PATH/conf/submodule_file

# git@github.com: .git