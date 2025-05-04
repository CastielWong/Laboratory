

## Initialization
```sh
make launch
make init
make start-dev
```

## Usage
1. Run `make retrieve-root-token` to get the root token
2. Wait for a minute for service to be up
3. Get to Vault's UI, either
   - run `make forward-vault-ui` to access via "localhost:8200"
   - run `make get-vault-ui` to access the temporary URL provided by Minikube

Generate items (secret, policy, etc.) in Vault server:
```sh
make forward-vault-ui
make set-env
make generate-item
```
