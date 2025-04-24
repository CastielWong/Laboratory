- [Script](#script)
- [Initialization](#initialization)

## Script
```sh
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root_token

export DUMP_FILE="tmp_vault_secret.dump"
```

## Initialization
```sh
# note down "Unseal Key" and the "Initial Root Token"
vault operator init

# run multiple times unitl the threshold of Sharmir's key shares is reached
vault opeartor unseal
```
