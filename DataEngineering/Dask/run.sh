#!/bin/sh

WORKSPACE="workspace"
DIR_HOME="/home/root"

# clean up Jupyter environment
find $WORKSPACE ! -name *.ipynb -delete

docker-compose up -d

docker exec lab-dask /bin/sh "${DIR_HOME}/init.sh"
