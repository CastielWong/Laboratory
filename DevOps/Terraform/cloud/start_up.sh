#!/bin/bash
# wait for the VM to get ready to avoid lock in package installation
# mainly for Azure, AWS and GCP do not need to sleep
sleep 20

sudo apt-get clean
sudo apt-get update -y
sudo apt-get install apache2 -y

echo '<!doctype html><html><body><h1>DEMO PAGE</h1> created via <b>Terraform</b>!</body></html>' | sudo tee /var/www/html/index.html
