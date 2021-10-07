#!/bin/sh

DIR_HOME="/home/root"

docker-compose up -d

docker exec lab-dask /bin/sh "${DIR_HOME}/init.sh"
