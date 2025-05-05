#!/bin/bash
set -eo pipefail

DIR_INPUT=tmp_migration/auth_methods

dashline() {
    printf "%.0s${1}" {1..80}; echo
}

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

validate_method() {
    local method_type="$1"
    case "${method_type}" in
        userpass|approle|ldap|oidc|github|token)
            return 0 ;;
        *)
            log "Unsupported auth method type: ${method_type}"
            return 1 ;;
    esac
}

import_auth_method() {
    local mount_path="$1"
    local config_file="${DIR_INPUT}/${mount_path}/config.json"

    [ ! -f "${config_file}" ] && {
        log "Missing config file for ${mount_path}, skipping"
        return
    }

    local method_type=$(jq -r '.data.type' "${config_file}")
    if ! validate_method "${method_type}"; then
        return
    fi

    log "Importing '${method_type}' at '${mount_path}'"

    # Enable auth method if not exists
    if ! vault auth list -format=json | jq -e ".[\"${mount_path}/\"]" >/dev/null; then
        vault auth enable -path="$mount_path" "$method_type" || {
            log "Error enabling ${method_type} at ${mount_path}"
            return
        }
    else
        log "Auth method '${mount_path}' already exists"
    fi

    # Apply method-specific configurations
    case "${method_type}" in
        userpass)
            import_userpass_config "${mount_path}"
            ;;
        approle)
            import_approle_config "${mount_path}"
            ;;
        token)
            log "Token auth method requires no additional configuration"
            ;;
        *)
            log "Generic auth method ${method_type} requires manual configuration"
            ;;
    esac

    # Apply tuning parameters if available
    local tune_file="${DIR_INPUT}/${mount_path}/tune.json"
    if [ -f "${tune_file}" ]; then
        log "Applying tuning parameters for ${mount_path}"
        tune_flags=$(jq -r '. | to_entries | map("-\(.key)=\(.value)") | join(" ")' "$tune_file")

        vault auth tune $tune_flags "${mount_path}/" || {
            log "Warning: Failed to apply tuning for ${mount_path}"
        }
    fi
}

import_userpass_config() {
    local path="$1"
    local users_dir="${DIR_INPUT}/${path}"

    [ ! -d "${users_dir}" ] && return

    log "Importing userpass users for ${path}"

    find "${users_dir}" -name '*.json' ! -name '*config.json' ! -name '*tune.json' | \
        while read -r user_file; do
            local username=$(basename "$user_file" .json)
            local password=$(jq -r '.data.password // empty' "$user_file")
            local policies=$(jq -r '.data.policies | join(",")' "$user_file")

            if [ -z "$password" ]; then
                log "Warning: No password found for user ${username}, skipping"
                continue
            fi

            log "Creating user ${username}"
            vault write "auth/${path}/users/${username}" \
                password="$password" \
                policies="$policies" || {
                log "Error creating user ${username}"
            }
        done
}

import_approle_config() {
    local path="$1"
    local roles_dir="${DIR_INPUT}/${path}"

    [ ! -d "$roles_dir" ] && return

    log "Importing approle roles for ${path}"

    find "$roles_dir" -name '*.json' ! -name '*_role_id.json' ! -name '*config.json' ! -name '*tune.json' | \
        while read -r role_file; do
            local role_name=$(basename "${role_file}" .json)

            log "Creating role ${role_name}"
            jq '.data' "${role_file}" | \
                vault write "auth/${path}/role/${role_name}" - || {
                log "Error creating role ${role_name}"
                continue
            }

            # Handle role ID if available
            local role_id_file="${roles_dir}/${role_name}_role_id.json"
            if [ -f "$role_id_file" ]; then
                local role_id=$(jq -r '.data.role_id' "$role_id_file")
                log "Setting role ID for ${role_name}"
                vault write "auth/${path}/role/${role_name}/role-id" \
                    role_id="${role_id}" || {
                    log "Warning: Failed to set role ID for ${role_name}"
                }
            fi
        done
}

### Main Execution ###
log "Starting Vault auth method import to ${VAULT_ADDR}"
log "Input directory: ${DIR_INPUT}"
dashline

[ ! -d "${DIR_INPUT}" ] && {
    log "Error: Input directory ${DIR_INPUT} not found"
    exit 1
}

# Import all auth methods from directory structure
find "${DIR_INPUT}" -mindepth 1 -maxdepth 1 -type d | \
    while read -r method_dir; do
        mount_path=$(basename "${method_dir}")
        import_auth_method "${mount_path}"
        dashline
    done

log "Auth method import completed"
echo "Note: Token auth method cannot be fully imported due to security constraints"
echo "      Some methods may require manual configuration post-import"



dashline "="
echo "Importing Entities..."
find "${dir_input}/entities" -name "*.json" | \
    while read -r entity_file; do
        entity_name=$(basename "${entity_file}" .json)
        echo "Processing entity: ${entity_name}"

        # Extract entity data and create
        jq '.data' "${entity_file}" | \
            vault write identity/entity name="${entity_name}" - || {
                echo "Error importing entity ${entity_name}"
            }
    done
