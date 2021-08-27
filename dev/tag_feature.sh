#！/bin/bash

poc_name=$1
description=$2

git tag -a latest-${poc_name} -m  "PoC: ${description}"
git push origin --tags
