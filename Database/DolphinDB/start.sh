#!/usr/bin/env bash

mode=$1

cd ${mode}

if [ -n ${mode} ]; then
    echo "Kicking off docker to launch DolphinDB with mode ${mode}"
    docker-compose up -d
else
    echo "Please input the mode wanted: [community|distributed]"
fi
