#!/bin/bash
# generate SSL certificate for KeyCloak
export DIR_CERT="ssl"
export CONF_FILE="openssl.cnf"

mkdir ./${DIR_CERT}/

# generate an RSA PK with size 2048 bits
openssl genrsa -out ./${DIR_CERT}/server.key 2048

# generate self-signed SSL certificate
# - req: create and precess certificate requests
# - -x509: specify the output should be a self-signed certificate
# - -key: specify the PK to use for signing the certificate
# - -conf: configuration file for SANs (Subject Alternative Names)
# - -subj: set the subject of certificate
# -     /L: the Locality Name
# -     /CN: Common Name, which is typically the domain name or hostname
openssl req -new -x509 \
    -key ./${DIR_CERT}/server.key \
    -out ./${DIR_CERT}/server.crt \
    -subj "/L=Hong Kong/CN=keycloak" \
    -config ./${CONF_FILE}

cp ./${DIR_CERT}/server.crt ./${DIR_CERT}/server.pem
cat ./${DIR_CERT}/server.key >> ./${DIR_CERT}/server.pem
