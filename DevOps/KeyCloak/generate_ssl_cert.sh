#!/bin/bash
# generate SSL certificate for KeyCloak
export DIR_CERT="ssl"
export KEYCLOAK_HOST_NAME="keycloak"

mkdir ./${DIR_CERT}/

# generate an RSA PK with size 2048 bits
openssl genrsa -out ./${DIR_CERT}/server.key 2048

# generate self-signed SSL certificate
# - req: create and precess certificate requests
# - -x509: specify the output should be a self-signed certificate
# - -key: specify the PK to use for signing the certificate
# - -subj: set the subject of certificate
# -     /C: the country code
# -     /CN: Common Name, which is typically the domain name or hostname
openssl req -new -x509 \
    -key ./${DIR_CERT}/server.key \
    -out ./${DIR_CERT}/server.crt \
    -subj "/C=HK/CN=${KEYCLOAK_HOST_NAME}"

cp ./${DIR_CERT}/server.crt ./${DIR_CERT}/server.pem
cat ./${DIR_CERT}/server.key >> ./${DIR_CERT}/server.pem
