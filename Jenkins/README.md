
This is used to explore Jenkins stuff. Docker and DOcker-Compose are used for the exploration.

```sh
docker pull jenkins/jenkins

# build up images
docker-compose build
# start up containers
docker-compose up -d

# check ip address after inet
ifconfig | grep "inet " | grep -v 127.0.0.1

docker logs -f {container_name}


docker-compose start/stop/restart
# delete the docker-compose
docker-compose down

```

Setup container:

```sh
docker exec -it -u root jenkins bash

apt-get install sudo vim -y
```

In Jenkins container
```sh
# connect to the remote host with password
ssh remote_user@remote_host

# connect to the remote host without password
ssh -i {remote_key} remote_user@remote_host
```

In remote host container:
```sh
# connect to MySQL database
mysql -u root -h db_host -p

```

In database container
```sh
mysql -u root -p
```

```sql
SHOW DATABASES;

DESC INFO;
```

## Jenkins UI

- General
    - This project is parameterized: Add environment variables
- Build Environment
    - Use secret text(s) or files(s): bind the secret paramters
- Build
    - Add build step: Config specific step


Other useful commands:

```sh
# add a user to a group
usermod -a -G {group} {user}
# remove a user from a group
gpasswd -d {user} {group}
```


"/etc/ssh/sshd_config"

- https://www.digitalocean.com/community/questions/error-permission-denied-publickey-when-i-try-to-ssh
- https://unix.stackexchange.com/questions/23291/how-to-ssh-to-remote-server-using-a-private-key
