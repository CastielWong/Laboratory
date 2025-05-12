#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=}
###############################################################################

DIR_SCRIPT_ABS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AUDIT_NAME="demo-audit"
AUDIT_FILE="audit_log.json"

echo ${DIR_SCRIPT_ABS}/other/${AUDIT_FILE}

curl -k --header "X-Vault-Token: ${VAULT_TOKEN}" \
    --request POST \
    --data @"${DIR_SCRIPT_ABS}/config/${AUDIT_FILE}" \
    ${VAULT_ADDR}/v1/sys/audit/${AUDIT_NAME}

######################################################################
# commands to verify

# vault audit list -detailed

# # check if "data" section contains content
# curl -k -s --header "X-Vault-Token: ${VAULT_TOKEN}" ${VAULT_ADDR}/v1/sys/audit | jq
