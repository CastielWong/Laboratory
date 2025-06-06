
This is the demo project for HashiCorp Vault.

- [Recipe](#recipe)
- [Usage](#usage)
  - [Prerequisite](#prerequisite)
  - [Initialization](#initialization)
    - [Development](#development)
    - [Non-Development](#non-development)
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

### Prerequisite
Install Vault CLI so as to interact with the Vault server set up.

For instance, below is the to install it and jQuery in MacOS via HomeBrew:
```sh
brew tap hashicorp/tap
brew install hashicorp/tap/vault

brew install jq
```


### Initialization
#### Development
To get to the development mode, make configuration in "docker-compose.yaml":
- set `VAULT_DEV_ROOT_TOKEN_ID`
- avoid lauching up Vault server with configuration file

#### Non-Development
For non-development setup, run commands below:
```sh
# note down "Unseal Key" and the "Initial Root Token"
vault operator init
# vault operator init -key-shares=3 -key-threshold=2

# run multiple times until the threshold of Sharmir's key shares is reached
vault operator unseal
```


## Concept
- Authentication: the process of confirming identity, often abbreviated to _AuthN_
- Authorization: the process of verifying what an entity has access to and at what level, often abbreviated to _AuthZ_
- Entity: represents a logical user, service, or application, which is a container
for identities from different authentication methods (e.g., AppRole, LDAP)
- Alias: an Alias links an authentication method's identity
- AppRole: the role configured in Vault that contains the authorization and usage parameters for the authentication
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

vault login -method=${type} ...

# check which auth methods are enabled
vault auth list -detailed
# get the accessor of the specified userpass through `jq`
vault auth list -format=json | jq -r '.["userpass-${name}/"].accessor'

vault auth enable -path='${name}' ${type}

# list existing roles
vault list auth/approle/role

vault list identity/entity/id
vault secrets list
vault policy list

# ============policy============
# create a new policy
vault policy write ${policy_name} -<<EOF
# comment
path "secret/data/*" {
    capabilities = [ "read" ]
}
EOF

# read a policy
vault policy read ${policy_name}

# ============approle============
vault auth enable approle

# create a new role
vault write auth/approle/role/${role_name} \
    token_policies="${policy_name}" \
    token_ttl=1h token_max_ttl=4h

# read the role for its settings
vault read auth/approle/role/${role_name}

# generate SecretID for the role
vault write -force auth/approle/role/${role_name}/secret-id

# retrieve RoleID/SecretID of a role through its name
vault read auth/approle/role/${role_name}/role-id
# list available secrets with their accessor
vault list auth/approle/role/${role_name}/secret-id

vault delete auth/approle/role/${role_name}
# ============entity============
# corresponding entity would be created automatically
vault write auth/approle/login role_id="" secret_id=""

vault write identity/entity name="${entity_name}" \
    policies="${policy-name}" \
    metadata=description="readable entity"

vault read -format=json identity/entity/id/${entity_id}
vault read identity/entity-alias/id/${alias_id}

# ============secret============
vault auth enable -path="userpass-${name}" userpass

vault kv list ${mount_path}

vault kv put -mount=${mount_path} ${item_name} ${key}=${value}
vault kv get -mount=${mount_path} ${item_name}

# ============audit============
vault audit list -detailed
curl -s --header "X-Vault-Token: ${VAULT_TOKEN}" ${VAULT_ADDR}/v1/sys/audit | jq

vault audit disable ${path_name}

# ============other============
vault auth disable ${auth}

vault token capabilities secret/${path}
```


## Reference
- Docker Image: https://hub.docker.com/r/hashicorp/vault
- Get Started: https://developer.hashicorp.com/vault/tutorials/get-started
- Implement identity entities and groups: https://developer.hashicorp.com/vault/tutorials/operations/identity
- Generate tokens for machine authentication with AppRole: https://developer.hashicorp.com/vault/tutorials/auth-methods/approle
- Learn to use the Vault CLI: https://developer.hashicorp.com/vault/tutorials/get-started/learn-cli
