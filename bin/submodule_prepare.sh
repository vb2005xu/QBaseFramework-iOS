#!/bin/bash



export BASE_PATH=${PWD}

mkdir -p $BASE_PATH/src/vendor
echo $BASE_PATH

cd $BASE_PATH/src/vendor

while read line
do
	git submodule add  --force git@github.com:"$line".git 
done < $BASE_PATH/conf/submodule_file

# git@github.com: .git