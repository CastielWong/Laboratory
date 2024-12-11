#!/bin/bash
export KEYCLOAK_HOME=/opt/keycloak

export HTTP_KEYCLOAK="http://keycloak.lab:8080"
export HTTPS_KEYCLOAK="https://keycloak.lab:8443"

export KEYCLOAK_SERVER=${HTTP_KEYCLOAK}

${KEYCLOAK_HOME}/bin/kcadm.sh config credentials \
    --server ${KEYCLOAK_SERVER} \
    --realm master \
    --user admin \
    --password admin

${KEYCLOAK_HOME}/bin/kcadm.sh create realms \
    --server ${KEYCLOAK_SERVER} \
    -s realm=demo \
    -s enabled=true

${KEYCLOAK_HOME}/bin/kcadm.sh create clients \
    -r demo \
    -s clientId=gitlab \
    -s name=gitlab-id \
    -s baseUrl="${HTTPS_KEYCLOAK}" \
    -s redirectUris='["https://keycloak.lab:8443/users/auth/openid_connect/callback"]' \
    -s webOrigins='["https://keycloak.lab:8443"]' \
    -s publicClient=false \
    -s enabled=true
