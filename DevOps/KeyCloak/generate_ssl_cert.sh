#!/bin/bash

mkdir ./ssl/

# generate an RSA PK with size 2048 bits
openssl genrsa -out ./ssl/server.key 2048

# generate self-signed SSL certificate
# - req: create and precess certificate requests
# - -x509: specify the output should be a self-signed certificate
# - -key: specify the PK to use for signing the certificate
# - -subj: set the subject of certificate
# -     /C: the country code
# -     /CN: Common Name, which is typically the domain name or hostname
openssl req -new -x509 \
    -key ./ssl/server.key \
    -out ./ssl/server.crt \
    -subj "/C=HK/CN=keycloak.lab"

cp ./ssl/server.crt ./ssl/server.pem
cat ./ssl/server.key >> ./ssl/server.pem
