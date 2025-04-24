
This is the demo project for HashiCorp Vault.

- [Recipe](#recipe)
- [Usage](#usage)
- [Concept](#concept)
- [Command](#command)
- [Reference](#reference)


## Recipe
| Command         | Description                              |
|-----------------|------------------------------------------|
| make start      | launch up container(s) for demo          |
| make end        | stop all relative container(s)           |
| make run        | access into the primary container        |
| make credential | grab the unseal key and root token       |
| make clean      | clean up container(s), volume(s) created |


## Usage
The Vault server is up by default, for which can be accessed via "127.0.0.1:8200".

Check container log for its "Root Token" and "Unseal Key", a default token is set for DEV.

Note that there are environment variables to set if not already:
```sh
# address the Vault server
export VAULT_ADDR=http://127.0.0.1:8200
# for Vault CLI to authenticate with the Vault server
export VAULT_TOKEN=

# TLS
export VAULT_CACERT='/var/.../vault-ca.pem'
```


## Concept
- Authentication: the process of confirming identity, often abbreviated to _AuthN_
- Authorization: the process of verifying what an entity has access to and at what level, often abbreviated to _AuthZ_
- Entity
- Alias
- AppRole role: the role configured in Vault that contains the authorization and usage parameters for the authentication
  - RoleID: the semi-secret identifier for the role that will authenticate to Vault, like the _username_ portion of an authentication pair
  - SecretID: the secret identifier for the role that will authenticate to Vault, like the _password_ portion of an authentication pair

Attributes:
- accessor: ID of specific item, like token, secret etc.
- secret_id: a sensitive piece of information used to authenticate to Vault when using an AppRole
- secret_id_accessor: a unique identifier for a specific secret_id


## Command
```sh
vault status

# check current token using
vault token lookup

vault login -method=<type> ...

# check which auth methods are enabled
vault auth list -detailed
# get the accessor of the specified userpass through `jq`
vault auth list -format=json | jq -r '.["userpass-{name}/"].accessor'

vault auth enable -path='<name>' {type}

# list existing roles
vault list auth/approle/role

vault list identity/entity/id
vault secrets list
vault policy list

# ============policy============
# create a new policy
vault policy write {policy_name} -<<EOF
# comment
path "secret/data/*" {
    capabilities = [ "read" ]
}
EOF

# ============role============
# create a new role
vault write auth/approle/role/{role_name} \
    token_policies="{policy_name}" \
    token_ttl=1h token_max_ttl=4h

# read the role for its settings
vault read auth/approle/role/{role_name}

# retrieve RoleID/SecretID of a role through its name
vault read auth/approle/role/{role_name}/role-id
vault list auth/approle/role/{role_name}/secret-id

# generate SecretID for the role
vault write -force auth/approle/role/{role_name}/secret-id

# ============entity============
# corresponding entity would be created automatically
vault write auth/approle/login role_id="" secret_id=""

vault write identity/entity name="{entity-name}" \
    policies="{policy-name}" \
    metadata=description="readable entity"

vault read -format=json identity/entity/id/{entity_id}
vault read identity/entity-alias/id/{alias_id}

# ============secret============
vault auth enable approle

vault auth enable -path="userpass-{name}" userpass

vault kv put -mount=<path> {name} {key}={value}
vault kv get -mount=<path> {name}
vault kv list {path}

# ============other============
vault token capabilities secret/{path}
```


## Reference
- Docker Image: https://hub.docker.com/r/hashicorp/vault
- Get Started: https://developer.hashicorp.com/vault/tutorials/get-started
- Implement identity entities and groups: https://developer.hashicorp.com/vault/tutorials/operations/identity
- Generate tokens for machine authentication with AppRole: https://developer.hashicorp.com/vault/tutorials/auth-methods/approle
- Learn to use the Vault CLI: https://developer.hashicorp.com/vault/tutorials/get-started/learn-cli
