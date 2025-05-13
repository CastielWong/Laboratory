#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=}
###############################################################################

separator() {
    printf "%.0s${1}" {1..80}
    echo
}

APPROLE_PATH="demo-approle"
DIR_SCRIPT_ABS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

_DIR_APPROLE="${DIR_SCRIPT_ABS}/tmp_approle"
mkdir ${_DIR_APPROLE}


declare -A approles=(
    ["apple"]="apple"
    ["banana"]="banana"
)


post_approle() {
    # note that it won't be visible in the AppRole output
    # when policies are embedded as inline JSON/HCL during creation
    local role_name=${1}
    local policy_file="${DIR_SCRIPT_ABS}/policy/${2}.hcl"

    if [[ ! -f "${policy_file}" ]]; then
        echo "Error: File '${policy_file}' is not found!" >&2
        return 1
    fi

    separator "-"

    curl -k -sLS \
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        --request POST \
        --data @"${policy_file}" \
        ${VAULT_ADDR}/v1/auth/approle/role/${role_name}

    # retrieve the RoleID
    curl -k -sLS \
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        ${VAULT_ADDR}/v1/auth/approle/role/${role_name}/role-id \
        | jq -r ".data"

    # generate SecretID for the role
    curl -k -sLS \
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        --request POST \
        ${VAULT_ADDR}/v1/auth/approle/role/${role_name}/secret-id \
        | jq -r ".data"

    separator "-"
}

# -----------------------------------------------------------------------------
# enable AppRole
if vault auth list | grep -q '^${APPROLE_PATH}/'; then
    echo "AppRole is already enabled."
else
    vault auth enable -path=${APPROLE_PATH} approle

    # curl -k -sSL \
    #     --header "X-Vault-Token: ${VAULT_TOKEN}" \
    #     --request POST \
    #     --data '{"type": "approle"}' \
    #     ${VAULT_ADDR}/v1/sys/auth/${APPROLE_PATH}
fi

# -----------------------------------------------------------------------------
# create AppRole
for role_name in "${!approles[@]}"; do
    echo "Creating AppRole '${role_name}'"

    payload_file="${_DIR_APPROLE}/${role_name}.txt"

    # option 1: Vault CLI - policy created
    # policies should be existed
    vault write auth/${APPROLE_PATH}/role/${role_name} \
        token_policies="${approles[${role_name}]}"

    vault read auth/${APPROLE_PATH}/role/${role_name}/role-id > ${payload_file}
    echo "" >> ${payload_file}
    # generate SecretID for the role
    vault write -force auth/${APPROLE_PATH}/role/${role_name}/secret-id >> ${payload_file}

    # # option 2: REST API - inline policy
    # post_approle ${role_name} ${approles[${role_name}]}
done

# -----------------------------------------------------------------------------
# create Entity and link AppRole with alias
for role_name in "${!approles[@]}"; do
    entity_alias="${role_name}_approle"

    echo "Creating Entity '${role_name}'"
    vault write identity/entity name="${role_name}"

    echo "Alias AppRole to the Entity - '${role_name}'"
    vault write identity/entity-alias \
        name="${entity_alias}" \
        canonical_id=$(vault read -field=id identity/entity/name/${role_name}) \
        mount_accessor=$(
            vault auth list -format=json |
            jq -r --arg path "${APPROLE_PATH}/" '.[$path].accessor'
        )
done
######################################################################
# commands to verify

# vault list auth/${APPROLE_PATH}/role

# vault read auth/${APPROLE_PATH}/role/${role_name}

# vault list auth/${APPROLE_PATH}/role/${role_name}/secret-id

# vault delete auth/${APPROLE_PATH}/role/${role_name}
