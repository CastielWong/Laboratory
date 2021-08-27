
## Running

Run [mySQL](https://hub.docker.com/_/mysql) container via:

```sh
# change directory to current one
cd MySQL

# create the container
docker run \
    --name lab_db_mysql \
    -e MYSQL_ROOT_PASSWORD=db_mysql \
    -p 3306:3306 \
    -v ${PWD}/data:/volume_docker \
    -d mysql:5.7.32

# when the container is already existed and running
docker exec -it lab_db_mysql bash

# stop and remove the container
docker stop lab_db_mysql && docker rm lab_db_mysql
```

Note that the default user is "root" and the password set above is "db_mysql". And directory "data" is mapped.

Inside the running container, run `mysql -h 127.0.0.1 -P 3306 -u root -p` to access MySQL.


## Query

Below is common administrative queries in MySQL:

```sql
SHOW DATABASES;

CREATE DATABASE IF NOT EXISTS {database};
CONNECT {database};

SHOW TABLES;

SELECT  column_name
FROM INFORMATION_SCHEMA.COLUMNS
WHERE   table_schema = '{db}'
    AND table_name = '{table}';
```
