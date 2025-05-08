#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=}
###############################################################################

DIR_SCRIPT_ABS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

declare -A fruits_1=(
    ["apple"]="apple.hcl"
    ["banana"]="banana.hcl"
    ["cherry"]="cherry.hcl"
)
declare -A fruits_2=(
    ["durian"]="durian.hcl"
    ["eggplant"]="eggplant.hcl"
)

separator() {
    printf "%.0s${1}" {1..80}; echo
}

post_policy() {
    local policy_name=${1}
    local policy_file=${2}

    policy_json=$(
        jq -n \
        --arg policy_content "$(cat ${policy_file})" \
        '{policy: $policy_content}'
    )

    curl -k -L \
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        --data "${policy_json}" \
        ${VAULT_ADDR}/v1/sys/policy/${policy_name}
}


for name in "${!fruits_1[@]}"; do
    separator "-"
    echo "Creating policy '${name}'"
    vault policy write "${name}" "${DIR_SCRIPT_ABS}/policy/${fruits_1[${name}]}"
done

for name in "${!fruits_2[@]}"; do
    separator "-"
    echo "Creating policy '${name}'"
    post_policy "${name}" "${DIR_SCRIPT_ABS}/policy/${fruits_2[${name}]}"
    echo "Policy '${name}' is created"
done
