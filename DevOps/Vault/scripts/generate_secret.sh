#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=}
###############################################################################

DIR_SCRIPT_ABS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SECRET_MOUNT="secret_mount.json"
SECRET_PAYLOAD="secret_payload.json"

KV_VIA_VAULT="demo-vault-cli"
KV_VIA_REST="demo-rest-api"

declare -A secrets=(
    ["${KV_VIA_VAULT}/data/cherry"]="cherry.json"
    ["${KV_VIA_REST}/data/durian"]="durian.json"
    ["${KV_VIA_REST}/data/eggplant"]="eggplant.json"
)

enable_secret_kv() {
    local mount_path=${1}
    local mount_file=${2}

    curl -k -L \
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        --request POST \
        --data @"${mount_file}" \
        ${VAULT_ADDR}/v1/sys/mounts/${mount_path}
}

post_secret_kv() {
    local secret_path=${1}
    local secret_file=${2}

    if [[ ! -f "${secret_file}" ]]; then
        echo "Error: File '${secret_file}' is not found!" >&2
        return 1
    fi

    curl -k -L -sS \
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        --request POST \
        --data @"${secret_file}" \
        ${VAULT_ADDR}/v1/${secret_path}
}

# -----------------------------------------------------------------------------
# enable secret engine
# option 1: Vault CLI
if vault kv get ${KV_VIA_VAULT} >/dev/null 2>&1; then
    echo "Secret - KV '${KV_VIA_VAULT}' exists already"
else
    vault secrets enable -path="${KV_VIA_VAULT}" kv-v2
fi

# option 2: REST API
echo "Enabling secret - kv '${KV_VIA_REST}'"
enable_secret_kv "${KV_VIA_REST}" "${DIR_SCRIPT_ABS}/config/${SECRET_MOUNT}"
# # -----------------------------------------------------------------------------
# # create secrets
# for secret_path in "${!secrets[@]}"; do
#     echo "Creating secrect in '${secret_path}/'"
#     post_secret_kv "${secret_path}" "${DIR_SCRIPT_ABS}/secret/${secrets[${secret_path}]}" || exit 1
# done
