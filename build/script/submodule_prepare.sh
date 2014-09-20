#!/bin/bash

cd ../../src/vendor

while read line
do
	git submodule add git@github.com:"$line".git
done < submodule_file

# git@github.com: .git