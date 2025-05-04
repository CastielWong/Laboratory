#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=root_token}
###############################################################################

dir_output=tmp_migration
directories=(
    secrets
    policies
    entities
    identity
)
dashline() {
    printf "%.0s${1}" {1..80}
    echo
}

for directory in "${directories[@]}"; do
    mkdir -p "${dir_output}/${directory}"
done

# export all KV v2 secrets, but not all kinds
echo "Export secrets..."

dir_secret="${dir_output}/secrets"

list_secrets() {
    local mount="$1"
    local sub_path="$2"

    mkdir -p ${dir_secret}/${mount}/${sub_path}

    local list_path="${mount}/${sub_path}"
    local list_path="${list_path%/}" # remove tailing slash

    echo "Listing path: ${list_path}"

    vault kv list -format=json "${list_path}" 2>/dev/null | \
        jq -r '.[]? // empty' | \
        while read -r secret; do
            if [[ "${secret}" == */ ]]; then
                if [ -z "${sub_path}" ]; then
                    local inner_secret="${secret%/}"
                else
                    local inner_secret="${sub_path}/${secret%/}"
                fi
                list_secrets "${mount}" "${inner_secret}"
            else
                local full_path="${list_path}/${secret}"
                local output_file="${dir_secret}/${list_path}/${secret}.json"

                echo "Running: vault kv get -format=json '${full_path}'"
                vault kv get -format=json "${full_path}" > ${output_file} || {
                    echo "Error exporting ${full_path}"
                    # exit 1
                }
            fi
        done

    dashline "-"
}

vault secrets list -format=json | \
    jq -r 'to_entries[] | select(.value.type == "kv") | .key | sub("/$"; "")' | \
    while read -r mount; do
        list_secrets ${mount} ""
    done

dashline "="

# Export policies
echo "Export policies..."

dir_policy="${dir_output}/policies"
vault policy list | while read policy; do
    if [ "${policy}" = "root" ]; then
        continue
    fi
    echo "Running: vault policy read '${policy}' > '${dir_policy}/${policy}.hcl'"
    vault policy read "${policy}" > "${dir_policy}/${policy}.hcl"
done

dashline "="


# Export auth methods
echo "Export authentication method..."

file_auth="${dir_output}/auth_methods.txt"
echo "Collecting all available authentication method"
vault auth list -format=json | jq -r 'keys[] | sub("/$"; "")' > ${file_auth}

dashline "="


# Export entities/aliases (if using identity system)
echo "Export entities..."

dir_entity="${dir_output}/entities"
vault list identity/entity/name | \
    tail -n +3 | \
    while read entity; do
        [ -z "${entity}" ] && continue  # skip empty entity

        echo "Processing entity '${entity}'"
        vault read -format=json "identity/entity/name/${entity}" > "${dir_entity}/${entity}.json"
done

dashline "="
