#!/bin/bash

echo "Building up the image..."
./sample/pack_ami.sh

wait

echo "Running Terraform to launch the constructed AMI..."
./launch_instance.sh
