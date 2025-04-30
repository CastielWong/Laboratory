#!/bin/bash
set -eo pipefail

###############################################################################
: ${VAULT_TOKEN:=}
: ${VAULT_ADDR:=}
: ${DIR_OUTPUT:=}
###############################################################################
DUMP_FILE=$1

# Validate environment variables for the NEW Vault server
if [[ -z "${VAULT_ADDR}" || -z "${VAULT_TOKEN}" || -z "${DUMP_FILE}" ]]; then
    echo "ERROR: Set 'VAULT_ADDR' and 'VAULT_TOKEN' for the NEW Vault server."
    exit 1
fi

if [[ ! -f "${DUMP_FILE}" ]]; then
    echo "ERROR: Dump file '${DUMP_FILE}' not found."
    exit 1
fi

# Extract all KV mounts from the dump file
MOUNTS_TO_CREATE=$(grep "Processing mount: " "${DUMP_FILE}" | awk '{print $3}' | sort -u)

# Mount KV v2 engines if they don't exist
echo "Mounting KV v2 engines..."
for mount in $MOUNTS_TO_CREATE; do
    if ! vault secrets list -format=json | jq -e ".[\"${mount}/\"]" >/dev/null; then
        echo "Mounting: ${mount}/"
        vault secrets enable -path="${mount}" kv-v2 || {
            echo "ERROR: Failed to mount ${mount}/"
            exit 1
        }
    fi
done

# Import secrets
echo "Importing secrets..."
TMP_PATH=$(mktemp)
TMP_DATA=$(mktemp)

# Parse the dump file and import secrets
while IFS= read -r line; do
    case "$line" in
        "Secret Path: "*)
            # Save the previous secret (if any)
            if [[ -s "$TMP_DATA" ]]; then
                echo "Importing: $(cat "$TMP_PATH")"
                VAULT_TOKEN="${VAULT_TOKEN}" VAULT_ADDR="${VAULT_ADDR}" \
                vault kv put "$(cat "$TMP_PATH")" "@$TMP_DATA" || {
                    echo "ERROR: Failed to import $(cat "$TMP_PATH")"
                    exit 1
                }
                > "$TMP_DATA"  # Reset data file
            fi
            # Capture the new path
            echo "${line#Secret Path: }" > "$TMP_PATH"
            ;;
        "------------------------"*|"Processing mount: "*)
            continue  # Skip separators and mount headers
            ;;
        *)
            # Append JSON data to the current secret
            if [[ -f "$TMP_PATH" ]]; then
                echo "$line" >> "$TMP_DATA"
            fi
            ;;
    esac
done < "${DUMP_FILE}"

# Import the last secret
if [[ -s "$TMP_DATA" ]]; then
    echo "Importing: $(cat "$TMP_PATH")"
    AULT_TOKEN="${VAULT_TOKEN}" VAULT_ADDR="${VAULT_ADDR}" \
    vault kv put "$(cat "$TMP_PATH")" "@$TMP_DATA" || {
        echo "ERROR: Failed to import $(cat "$TMP_PATH")"
        exit 1
    }
fi

# Cleanup
rm -f "$TMP_PATH" "$TMP_DATA"
echo "All secrets imported successfully!"
