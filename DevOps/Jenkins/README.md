
Here includes basic and custom demo:
- basic: Jenkins + GitLab, to illustrate the basic usage of Jenkinsfile
- custom: Jenkins + Ansible, to demonstrate how Ansible works with Jenkins

## Basic
The demo is derived from https://www.jenkins.io/doc/pipeline/tour/hello-world/.

After containers are up:
- Jenkins
  - access it via "localhost:8080"
  - the initial password can be found at "/var/jenkins_home/secrets/"
  - install the plugin:
    1. "Manage Jenkins"
    2. -> "Plugins"
    3. -> "Available plugins"
    4. -> search for "Docker Pipeline"
    5. -> check then "Install"
- GitLab
  - access it via "localhost:80", it could take 5 - 10 minutes for it to be up
  - the account:
    - username: root
    - password: can be found at "/etc/gitlab/initial_root_password"
  - update the password for "root" account or generate key for SSH connection

Regarding to "Jenkinsfile":
1. GitLab: Login to GitLab
2. Gitlab: Create a new project
3. Jenkins: Clone the project repo
4. Jenkins: Config git via
   - `git config --global user.email "demo@demo.com"`
   - `git config --global user.name "demo"`
5. Jenkins: Compile "Jenkinsfile", add to the repo then push


## Custom
Refer to the README in the directory.


## Link
There are links that useful during development:
- https://${JENKINS_SITE}/pipeline-syntax/globals


Check:
- how to set environment properly
- Jenkins API？
