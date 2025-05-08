#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=}

: ${VAULT_DIR_MIGRATION:=}
DIR_INPUT="${VAULT_DIR_MIGRATION}"
###############################################################################

separator() {
    printf "%.0s${1}" {1..80}
    echo
}

directories=(
    secrets
    policies
    entities
    identity
)

validate_input() {
    if [ ! -d "${DIR_INPUT}" ]; then
        echo "Error: Input directory '${DIR_INPUT}' not found"
        exit 1
    fi
    for dir in "${directories[@]}"; do
        if [ ! -d "${DIR_INPUT}/${dir}" ]; then
            echo "Warning: Missing subdirectory ${DIR_INPUT}/${dir}"
        fi
    done
}

# import KV-v2 Secrets
import_secrets() {
    local v_mount_path="${1%/}"   # remove tailing slash
    local v_secret_path="${2// }" # remove tailing spaces

    v_dir_secret="${v_mount_path}${v_secret_path:+/${v_secret_path}}"

    echo "Creating KV-v2 mount at ${v_mount_path}"
    vault secrets enable -version=2 -path="${v_mount_path}" kv || {
        echo "Warning: Mount '${v_mount_path}/' may already exist"
    }

    dir_secret="${DIR_INPUT}/secrets/${v_dir_secret}"
    find "${dir_secret}" -name "*.json" | \
    while read -r rel_secret_path; do
        local secret_file=$(basename ${rel_secret_path})
        local v_full_secret_path="${v_dir_secret}/${secret_file%.json}"

        echo "Importing secret: ${v_full_secret_path}"
        jq '.data.data' "${rel_secret_path}" | \
            vault kv put "${v_full_secret_path}" - || {
                echo "Error importing ${v_full_secret_path}"
            }
    done
}

# Main Import Process
validate_input

separator "="
echo "Importing KV-v2 Secrets..."
find "${DIR_INPUT}/secrets" -mindepth 1 -maxdepth 1 -type d | \
    while read -r mount_dir; do
        mount_name=$(basename "${mount_dir}")

        if [[ "${mount_name}" == "secret" ]]; then
            echo "Skip the default '${mount_name}/' "
            continue
        fi

        import_secrets "${mount_name}" ""
    done

separator "="
echo "Importing Policies..."
find "${DIR_INPUT}/policies" -name "*.hcl" | \
    while read -r policy_file; do
        policy_name=$(basename "${policy_file}" .hcl)

        if [ "$(basename "${policy_name}")" = "default" ]; then
            echo "Skip '${policy_name}' Policy"
            continue
        fi

        echo "Importing policy: ${policy_name}"
        vault policy write "${policy_name}" "${policy_file}" || {
            echo "Error importing policy ${policy_name}"
        }
    done

separator "="
echo "Migration completed with warnings (if any)"
