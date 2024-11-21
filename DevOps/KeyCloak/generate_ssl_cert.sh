#!/bin/bash

mkdir ./ssl/

openssl genrsa -out ./ssl/server.key 2048

openssl req -new -x509 \
    -key ./ssl/server.key \
    -out ./ssl/server.crt \
    -subj "/C=HK/CN=localhost"

# verify the certificate
openssl x509 -in ./ssl/server.crt -text -noout

cp ./ssl/server.crt ./ssl/server.pem
cat ./ssl/server.key >> ./ssl/server.pem
