#!/bin/bash
set -uo pipefail

###############################################################################
: ${VAULT_TOKEN:=root_token}
: ${VAULT_ADDR:=}
: ${DIR_OUTPUT:=tmp_output}
###############################################################################

dashline() {
    printf "%.0s${1}" {1..80}
    echo
}

mkdir -p ${DIR_OUTPUT}
dashline "="

# ###############################################################################
SECRET_KV_DEMO=demo
SECRET_KV_FRUIT=fruit

# create secrets
if vault kv get ${SECRET_KV_DEMO} >/dev/null 2>&1; then
    echo "Secret - KV exists at '${SECRET_KV_DEMO}/'"
else
    echo "Creating '${SECRET_KV_DEMO}'..."
    vault secrets enable -path=${SECRET_KV_DEMO} kv-v2
    vault kv put ${SECRET_KV_DEMO}/creds username="demo" password="s3cr3t!"
fi

if vault kv get ${SECRET_KV_FRUIT} >/dev/null 2>&1; then
    echo "Secret - KV exists at '${SECRET_KV_FRUIT}/'"
else
    echo "Creating secret - KV '${SECRET_KV_FRUIT}'..."
    vault secrets enable -path=${SECRET_KV_FRUIT} kv-v2
    vault kv put ${SECRET_KV_FRUIT}/info/apple weight="1kg" price="5"
    vault kv put ${SECRET_KV_FRUIT}/info/berry weight="250g" price="30"
fi

dashline "="

# ###############################################################################
POLICY_NAME="demo-policy"
POLICY_FILE="${POLICY_NAME}.hcl"
PATH_POLICY="${DIR_OUTPUT}/${POLICY_FILE}"

if vault policy read ${POLICY_NAME} >/dev/null 2>&1; then
    echo "Policy '${SECRET_KV_FRUIT}' is existed"
else
    echo "Creating Policy '${POLICY_NAME}'..."
    cat <<-EOF  | sed 's/^[ ]{4}//' > ${PATH_POLICY}
path "${SECRET_KV_FRUIT}/data/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
    vault policy write ${POLICY_NAME} ${PATH_POLICY}
EOF

    vault policy write ${POLICY_NAME} ${PATH_POLICY}
fi

dashline "="
# ###############################################################################
APPROLE_NAME="demo-role"

# enable AppRole auth method if not
vault auth enable approle >/dev/null 2>&1

if vault read auth/approle/role/${APPROLE_NAME} >/dev/null 2>&1; then
    echo "AppRole '${APPROLE_NAME}' is existed"
else
    echo "Creating AppRole '${APPROLE_NAME}'..."
    vault write auth/approle/role/${APPROLE_NAME} \
        token_policies="default"
        token_ttl="1h"

    # retrieve role ID and secret ID
    ROLE_ID=$(vault read -field=role_id auth/approle/role/${APPROLE_NAME}/role-id)
    SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/${APPROLE_NAME}/secret-id)
fi

# # login with AppRole
# vault write auth/app/login role_id="${ROLE_ID}" secret_id="${SECRET_ID}"

dashline "="
###############################################################################
vault list auth/token/accessors

echo "Creating tokens..."

# create a token with a policy
vault token create -policy="${POLICY_NAME}" -ttl="24h"

# create an orphan token
vault token create -policy="${POLICY_NAME}" -orphan

# create a wrapped token (for secure handoff)
vault token create -policy="${POLICY_NAME}" -wrap-ttl="5m"

dashline "="
# ###############################################################################
USERPASS_NAME="demo-user"
USERPASS_PASS="qwe123"

# enable UserPass auth method if not
vault auth enable userpass >/dev/null 2>&1

if vault read auth/userpass/users/${USERPASS_NAME} >/dev/null 2>&1; then
    echo "UserPass '${USERPASS_NAME}' is existed"
else
    echo "Creating UserPass '${APPROLE_NAME}'..."
    vault write auth/userpass/users/${USERPASS_NAME} \
        password="${USERPASS_PASS}" \
        policies="${POLICY_NAME}"
fi

# # login with UserPass
# vault login -method=userpass username=${USERPASS_NAME} password=${USERPASS_PASS}

dashline "="
# ###############################################################################
ENTITY_NAME="demo-entity"

if vault list identity/entity/name 2>/dev/null | grep -q "^${ENTITY_NAME}$"; then
    echo "Entity '${ENTITY_NAME}' is existed"
else
    echo "Creating Entity '${ENTITY_NAME}'..."
    vault write identity/entity \
        name="${ENTITY_NAME}" \
        metadata-team="engineering" \
        policies="${POLICY_NAME}"
fi


ENTITY_ID=$(vault read -field=id identity/entity/name/${ENTITY_NAME})

# link UserPass to the entity
echo "Linking UserPass '${USERPASS_NAME}' to Entity '${ENTITY_NAME}'"
USERPASS_ACCESSOR=$(vault auth list -format=json | jq -r '.["userpass/"].accessor')
vault write identity/entity-alias \
    name="${USERPASS_NAME}" \
    canonical_id="${ENTITY_ID}" \
    mount_accessor="${USERPASS_ACCESSOR}"

# link AppRole to the entity
echo "Linking AppRole '${APPROLE_NAME}' to Entity '${ENTITY_NAME}'"
APPRLE_ACCESSOR=$(vault auth list -format=json | jq -r '.["approle/"].accessor')
vault write identity/entity-alias \
    name="${APPROLE_NAME}" \
    canonical_id="${ENTITY_ID}" \
    mount_accessor="${APPRLE_ACCESSOR}"

echo "Check Entity '${ENTITY_NAME}'"
vault read identity/entity/name/${ENTITY_NAME}
dashline "="
# ###############################################################################

echo "List Secrets:"
echo "Secrets in ${SECRET_KV_DEMO}"
vault kv list ${SECRET_KV_DEMO}/
dashline "-"
echo "Secrets in ${SECRET_KV_FRUIT}"
vault kv list ${SECRET_KV_FRUIT}/info/
dashline "*"

echo "List Policies:"
vault policy list
dashline "*"

echo "List AppRoles:"
vault list auth/approle/role
dashline "*"

echo "List Tokens:"
vault list -format=json auth/token/accessors

echo "Token details"
ACCESSORS=$(vault list -format=json auth/token/accessors | jq -r '.[]')
for accessor in ${ACCESSORS}; do
    vault token lookup -format=json -accessor "${accessor}" | \
        jq '.data | {accessor, expire_time, orphan, path, policies, ttl, type}'
    dashline "-"
done
# WqXenL29rTcN81trnqET41Vn

dashline "*"

echo "List UserPass:"
vault list auth/userpass/users
dashline "*"

echo "List Entity:"
vault list identity/entity/name
dashline "*"

# ###############################################################################
echo "Cleaning up..."
rm -rf ${DIR_OUTPUT}
