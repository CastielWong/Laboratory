
- [Docker Compose](#docker-compose)
    - [Container - Jenkins](#container---jenkins)
    - [Container - Remote](#container---remote)
    - [Container - Database](#container---database)
- [Jenkins UI](#jenkins-ui)
    - [Email Notification](#email-notification)
- [Reference](#reference)


This is used to explore Jenkins stuff. Docker and Docker-Compose are used for the exploration.

Below lists common and useful commands:

```sh
docker exec -it -u root jenkins bash

# install sudo and vim for the container
apt-get install sudo vim -y

# add a user to a group
usermod -a -G {group} {user}
# remove a user from a group
gpasswd -d {user} {group}

# change the owner of a directory
chown {user}:{group} {directory} -R
```


## Docker Compose

To orchestrate contianers, Docker Compose is applied to handle the communication between containers.

Directoryies below are for volume mapping, Docker will create such directory automatically if not existed yet:
- "jenkins_home": needed for Jenkins container to keep all of Jenkins environment and contents
- "db_data": needed for the database container

To start, run `ssh-keygen -f remote-key` to generate SSH key, which is for the use of secure connection between container Jenkins and remote server.
Note that the generated public and private key would be hardcoded and mapped to:
- "centos7/Dockerfile": remote server needs public key for authetication
- "ansible/hosts": Ansible needs private key to access remote server

```sh
# build up images
docker-compose build

# start up containers
docker-compose up -d

docker-compose start/stop/restart
# check logs
docker logs -f {container_name}

# delete containers docker-compose raised
docker-compose down
```

Run `ifconfig | grep "inet " | grep -v 127.0.0.1` to retrieve ip address for current host. Grap the initial password from  "jenkins_home/secrets/initialAdminPassword" then go to {ip:8080} to start the Jenkins.


### Container - Jenkins

For Ansible playbook, copy files needed for the container:

```sh
# copy the SSH key for remote connection
docker cp centos7/remote-key jenkins:/tmp/ansible/
# copy other files needed for the container
docker cp ansible/play.yml jenkins:/tmp/ansible/
docker cp ansible/hosts jenkins:/tmp/ansible/
```

Inside container:

```sh
# connect to the remote host with password
ssh {remote_user}@{remote_host}

# connect to the remote host without password
# note: make sure the user has permission to the key
ssh -i {key_file} {remote_user}@{remote_host}

# ---------------Ansible----------------
# after config hosts for Ansible
ansible -i hosts -m ping {server}

ansible-playbook -i hosts {playbook}
```

After install Ansible inside Jenkins image, create "~/.ansible.cfg" and apeend content below to solve "Failed to connect to the host via ssh: Control socket connect" issue:

```sh
[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s
control_path = /dev/shm/cp%%h-%%p-%%r
```

### Container - Remote

A container is used to simulate a remote server:

```sh
# connect to MySQL database
mysql -u root -h db_host -p
```

There could be issues for SSH communication between Jenkins and the remote server when configing via Jenkins UI, try:
- Check if "/etc/ssh/sshd_config" is correctly setup
- In "/etc/passwd", update "jenkins:{group}:1000:1000:..." to "jenkins:{group}:1000:0:..." to make user "jenkins" in root group

Check links in Reference for more information.


### Container - Database

Run `mysql -u root -p` to access MySQL.

Common statements for MySQL:

```sql
SHOW DATABASES;

DESC INFO;
```



## Jenkins UI

Plugins to install:

- SSH
- Ansible
- AnsiColor
- Role-based Authorization Strategy
- Job DSL

Configuration:

- General
    - This project is parameterized: Add environment variables
- Build Environment
    - Use secret text(s) or files(s): bind the secret paramters
    - Color ANSI Console Output: display output with colored text
- Build
    - Add build step: Config specific step
    - Advanced...
        - Colorized stoud

### Email Notification

Use Gmail for the email notification.

- SMTP server: smtp.gmail.com
- Use SMTP Authentication
    - Use SSL
    - SMTP Port: 465

Note that Gmail restricts integration like Jenkins, so it's needed to set [Less secure app access](https://myaccount.google.com/lesssecureapps) feature off to ensure it works.


## DSL

DSL: Domain-Specific Language

To run DSL, config a job with "Process Job DSLs" in _Build_.


## Reference

- https://www.digitalocean.com/community/questions/error-permission-denied-publickey-when-i-try-to-ssh
- https://unix.stackexchange.com/questions/23291/how-to-ssh-to-remote-server-using-a-private-key
- Become a DevOps Jenkins Master: https://www.udemy.com/course/jenkins-from-zero-to-hero/
- Jenkins Job DSL API: https://jenkinsci.github.io/job-dsl-plugin/
- Pipeline: https://www.jenkins.io/doc/book/pipeline/
