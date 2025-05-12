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

DIR_SCRIPT_ABS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

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
if vault auth list | grep -q '^approle/'; then
    echo "AppRole is already enabled."
else
    vault auth enable approle

    # curl -k -sSL \
    #     --header "X-Vault-Token: ${VAULT_TOKEN}" \
    #     --request POST \
    #     --data '{"type": "approle"}' \
    #     ${VAULT_ADDR}/v1/sys/auth/approle
fi

# -----------------------------------------------------------------------------
# create AppRole
for role_name in "${!approles[@]}"; do
    echo "Creating AppRole '${role_name}'"

    # option 1: Vault CLI - policy created
    # policies should be existed
    vault write auth/approle/role/${role_name} \
        token_policies="${approles[${role_name}]}"

    vault read auth/approle/role/${role_name}/role-id

    # generate SecretID for the role
    vault write -force auth/approle/role/${role_name}/secret-id

    # # option 2: REST API - inline policy
    # post_approle ${role_name} ${approles[${role_name}]}
done

######################################################################
# commands to verify

# vault list auth/approle/role

# vault read auth/approle/role/${role_name}

# vault list auth/approle/role/${role_name}/secret-id

# vault delete auth/approle/role/${role_name}
