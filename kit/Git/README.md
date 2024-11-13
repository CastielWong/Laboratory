

## Setup
1. Generate SSH Key: `ssh-keygen -t ed25519 -C "<account_name>" -f "${HOME}/.ssh/id_<name>"`
   1. follow instruction to generate the key
   2. go to the key path, which should be "~/.ssh/" by default
   3. copy the public key and paste to the repo vendor
2. Clone the repo: `git clone git@xxx`

## Activate
1. git needs an SSH agent running to use the key: `eval $(ssh-agent)`
2. Add the key to agent for activation: `ssh-add ${HOME}/.ssh/id_gitlab`

## Configuration
To view the configuration, either run `git config --list` or check "~/.gitconfig"
the default configuration directory.

Some useful commands:
```sh
git config --global http.sslVerify false
git config --global user.name "{name}"
git config --global user.email "{name}@{email}"
```
