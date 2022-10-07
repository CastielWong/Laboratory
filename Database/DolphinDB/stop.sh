#!/usr/bin/env bash

mode=$1

cd ${mode}

if [ -n ${mode} ]; then
    echo "Stopping DolphinDB with mode ${mode}..."
    docker-compose down
else
    echo "Please input the mode wanted: [community|distributed]"
fi
