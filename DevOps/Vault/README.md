



This is the demo project for HashiCorp Vault.

- [Recipe](#recipe)
- [Usage](#usage)
- [Reference](#reference)


## Recipe
| Command    | Description                              |
|------------|------------------------------------------|
| make start | launch up container(s) for demo          |
| make run   | access into the primary container        |
| make end   | stop all relative container(s)           |
| make clean | clean up container(s), volume(s) created |


## Usage
The Vault server is up by default, for which can be accessed via "127.0.0.1:8200".

Check container log for its "Root Token" and "Unseal Key".


## Reference
- Get Started: https://developer.hashicorp.com/vault/tutorials/get-started
- Docker Image: https://hub.docker.com/r/hashicorp/vault
