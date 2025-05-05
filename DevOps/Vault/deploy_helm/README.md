
Deploying HashiCorp Vault via Helm.

- [Initialization](#initialization)
- [Usage](#usage)
  - [Common Command](#common-command)
- [Reference](#reference)

## Initialization
```sh
# launch Minikube for k8s cluster
make launch
# create namespace
make init

make start-dev
```

## Usage
There are 2 ways to access Vault's UI, either
- run `make forward-vault-ui` to access via "localhost:8200"
- run `make get-vault-ui` to access the temporary URL provided by Minikube

Forwarding is preferred as it enables us to utilize Vault CLI easily:
- steps following would go with forwarding way
- it would take effect only when services are up

1. Run `make retrieve-root-token` to get the root token
2. Wait for several minutes for services to be up
3. Run `make set-namespace` to point to the dedicated namespace
4. Run `make forward-vault-ui` to forward Vault's address
5. Run `make set-env` to set up environment variables for Vault's CLI utilization

Receipt for use case:
- `make generate-items`
- `make export-items`
- `make import-items`



### Common Command
```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault

# list available releases
helm search repo hashicorp/vault -l

helm status vault

helm get manifest vault

helm list


helm uninstall vault
```

## Reference
- Helm Chart: https://developer.hashicorp.com/vault/docs/deploy/kubernetes/helm
