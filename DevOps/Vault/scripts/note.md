- [Script](#script)
- [Initialization](#initialization)
  - [Development](#development)
  - [Non-Development](#non-development)

## Script
The "generate.sh" would generate:
- Secrets in KV
- Policy
- Authentication Methods
  - approle/
  - token/
  - userpass/
- Entity
  - Alias with UserPass and AppRole

Set environment variables below for  "secrets-*.sh" scripts:
```sh
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root_token

export DUMP_FILE="tmp_vault_secret.dump"
```

Then run like:
```sh
bash ./secrets-retrieval.sh > ${DUMP_FILE}

bash ./secrets-import.sh ${DUMP_FILE}
```
