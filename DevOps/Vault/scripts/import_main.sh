#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=root_token}
###############################################################################

dir_input=tmp_migration  # Must match export directory
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

validate_input() {
    if [ ! -d "${dir_input}" ]; then
        echo "Error: Input directory '${dir_input}' not found"
        exit 1
    fi
    for dir in "${directories[@]}"; do
        if [ ! -d "${dir_input}/${dir}" ]; then
            echo "Warning: Missing subdirectory ${dir_input}/${dir}"
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

    dir_secret="${dir_input}/secrets/${v_dir_secret}"
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

dashline "="
echo "Importing KV-v2 Secrets..."
find "${dir_input}/secrets" -mindepth 1 -maxdepth 1 -type d | \
    while read -r mount_dir; do
        mount_name=$(basename "${mount_dir}")

        if [[ "${mount_name}" == "secret" ]]; then
            echo "Skip the default '${mount_name}/' "
            continue
        fi

        import_secrets "${mount_name}" ""
    done

dashline "="
echo "Importing Policies..."
find "${dir_input}/policies" -name "*.hcl" | \
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

dashline "="
echo "Migration completed with warnings (if any)"
