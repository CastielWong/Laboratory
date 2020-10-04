

Run [mySQL](https://hub.docker.com/_/mysql) instance via:

```sh
docker run \
--name lab_mysql \
-e MYSQL_ROOT_PASSWORD=lab_mysql \
-p 3306:3306 \
-v {local_dir}:/volume_docker \
-d mysql:latest

docker exec -it lab_sql bash

# access MySQL when inside the container
mysql [-h 127.0.0.1 -P 3306] -u root -p
```
