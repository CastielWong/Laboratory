
Since the RDS is created inside a private subset, so it's needed to get into the provided instance so that to access the database.

Connect to the instance, then run:

```sh
sudo apt-get install sql-client

mysql -h {rds_url} -u {user} -p"{password}"
```
