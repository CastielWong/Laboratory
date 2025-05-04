#!/bin/bash
set -uo pipefail

###############################################################################
# Configuration
: ${VAULT_ADDR:=}
: ${VAULT_TOKEN:=root_token}
: ${OUTPUT_DIR:="vault_auth_export_$(date +%Y%m%d%H%M%S)"}
###############################################################################

dir_output=tmp_migration

dashline() {
    printf "%.0s${1}" {1..80}; echo
}


log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

DIR_AUTH_METHOD="${dir_output}/auth_methods"
mkdir -p ${DIR_AUTH_METHOD}

# Export auth methods
echo "Export auth method configurations..."

export_auth_method() {
    local v_mount_path=${1}
    local method_type=$(vault auth list -format=json | jq -r ".[\"${v_mount_path}\"].type")

    v_mount_path="${v_mount_path%/}"

    log "Processing '${method_type}' at '${v_mount_path}'"

    dir_output="${DIR_AUTH_METHOD}/${v_mount_path}"

    mkdir -p ${dir_output}

    # export base configuration
    vault read -format=json "sys/auth/${v_mount_path}" > "${dir_output}/config.json" 2>/dev/null || {
        log "Warning: Failed to export config for '${v_mount_path}'"
    }

    case "${method_type}" in
        userpass)
            export_userpass_method
            ;;
        approle)
            export_approle_method
            ;;
        token)
            export_token_method
            ;;
        *)
            export_generic_method "${v_mount_path}"
            ;;
    esac
}

export_userpass_method() {
    local method="userpass"
    local dir_output="${DIR_AUTH_METHOD}/${method}"

    log "Exporting '${method}' users"

    vault list -format=json "auth/${method}/users" 2>/dev/null | jq -r '.[]' | while read -r user; do
        vault read -format=json "auth/${method}/users/${user}" > "${dir_output}/${user}.json" || {
            log "Error exporting user ${user}"
        }
    done
}

export_approle_method() {
    local method="approle"
    local dir_output="${DIR_AUTH_METHOD}/${method}"

    log "Exporting '${method}'"

    vault list -format=json "auth/${method}/role" 2>/dev/null | jq -r '.[]' | while read -r role; do
        vault read -format=json "auth/${method}/role/${role}" > "${dir_output}/${role}.json" || {
            log "Error exporting role ${role}"
        }

        # Export role ID only (secret IDs are security-sensitive)
        vault read -format=json "auth/${method}/role/${role}/role-id" > \
            "${dir_output}/${role}_role_id.json" 2>/dev/null || {
            log "Warning: Failed to export role-id for ${role}"
        }
    done
}

export_token_method() {
    local method="token"
    local dir_output="${DIR_AUTH_METHOD}/${method}"

    log "Exporting 'token' accessors (excluding actual tokens)"

    vault list -format=json "auth/${method}/accessors" 2>/dev/null > \
        "${dir_output}/token_accessors.json" || {
        log "Error exporting token accessors"
    }
}

export_generic_method() {
    local method="$1"
    local dir_output="${DIR_AUTH_METHOD}/${method}"

    log "Exporting generic auth method data for ${method}"

    vault list -format=json "auth/${method}" 2>/dev/null > \
        "${dir_output}/entities.json" || {
        log "Error exporting entities"
    }
}

export_tuning_params() {
    log "Exporting auth method tuning parameters"

    vault auth list -format=json | jq -r 'keys[]' | while read -r v_mount_path; do
        # local clean_path=$(echo "${v_mount_path}" | sed 's|/$||')
        v_mount_path="${v_mount_path%/}"
        vault read -format=json "sys/auth/${v_mount_path}/tune" > \
            "${DIR_AUTH_METHOD}/${v_mount_path}/tune.json" 2>/dev/null || {
            log "Warning: Failed to export tuning for ${v_mount_path}"
        }
    done
}

# ### Main Execution ###

# Export all auth methods
vault auth list -format=json | jq -r 'keys[]' | while read -r v_mount_path; do
    export_auth_method "${v_mount_path}"
    dashline "="
done

# Export tuning parameters
export_tuning_params

dashline "="
log "Export completed. Security note:"
echo "1. Secret IDs for AppRole were NOT exported (security best practice)"
echo "2. Actual token values were NOT exported (security best practice)"
echo "3. Review exported data before sharing or importing elsewhere"
