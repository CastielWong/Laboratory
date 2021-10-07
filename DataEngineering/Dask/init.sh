#!/bin/sh

echo "Initializing the environment..."

apt-get update
apt-get install graphviz -y

pip install \
    dask[complete] \
    graphviz \
    dask-labextension

echo "Finish initialization."
