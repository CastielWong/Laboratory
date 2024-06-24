
Since the RDS is created inside a private subset, it's needed to get into the
provided instance for database accessing.

Connect to the instance, then run:
```sh
sudo apt-get install -y mysql-client

mysql -h {rds_url} -u {user} -p"{password}"
```
