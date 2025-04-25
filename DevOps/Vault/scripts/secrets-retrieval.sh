#!/bin/bash
set -eo pipefail

###############################################################################
: ${VAULT_TOKEN:=}
: ${VAULT_ADDR:=}
: ${DUMP_FILE:=}
###############################################################################

if [[ -z ${VAULT_ADDR} || -z ${VAULT_TOKEN} ]]; then
    echo "ERROR: Please set 'VAULT_ADDR' and 'VAULT_TOKEN'."
    exit 1
fi

normalize_mount_path() {
    local path="$1"
    echo "${path%/}"
}

# fetch mounted secrets engines "cubbyhold, kv, identity, system"
MOUNTS=$(
    curl -s -H "X-Vault-Token: ${VAULT_TOKEN}" ${VAULT_ADDR}/v1/sys/mounts |
    jq -r '.data | to_entries[] | .key'
)

function traverse_secrets() {
    local mount_path="$1"
    local subpath="$2"

    list_path="${mount_path}/metadata/${subpath}"
    list_response=$(
        curl -s -H "X-Vault-Token: ${VAULT_TOKEN}" "${VAULT_ADDR}/v1/${list_path}?list=true"
    )
    entries=$(
        echo "${list_response}" |
        jq -r '.data.keys[]?' 2>/dev/null
    )

    for entry in $entries; do
        if [[ $entry == */ ]]; then
            traverse_secrets "${mount_path}" "${subpath}${entry}"
        else
            secret_data=$(
                curl -s -H "X-Vault-Token: ${VAULT_TOKEN}" "${VAULT_ADDR}/v1/${mount_path}/data/${subpath}${entry}" |
                jq '.data.data'
            )

            echo "Secret Path: ${mount_path}/${subpath}${entry}"
            echo "${secret_data}"
        fi
    done
}

echo "${MOUNTS}" | while read -r mount; do
    echo "------------------------"
    mount=$(normalize_mount_path "${mount}")
    echo "Processing mount: ${mount}"
    traverse_secrets "${mount}" ""
done
