
## SSH
Set up SSH key in GitLab for convenience:
1. Generate SSH Key in Jenkins like: `ssh-keygen -t ed25519 -C "demo" -f "${HOME}/.ssh/id_gitlab"`
   1. follow instruction to generate the key
   2. add the private key to SSH agent:
      1. `eval $(ssh-agent)`
      2. `ssh-add ${HOME}/.ssh/id_gitlab`
   3. fetch the public key via `cat "${HOME}/.ssh/id_gitlab.pub"` by default
   4. copy the public key and paste to the repo vendor
2. Go to GitLab to add the public key:
   1. select the icon
   2. -> "Preferences"
   3. -> "SSH Keys"
   4. -> "Add new key" and complete
