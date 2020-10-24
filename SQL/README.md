
This repo is for general SQL stuff.

## DBeaver

[DBeaver](https://dbeaver.io/) is a good tool as a database studio.

### Oracle Database

The configuration is:

- Host: localhost / 127.0.0.1
- Post: 1521
- Database: XE (depends on which edition used, Service Name)
- Default Database: ORCL

### MySQL

The configuration is:

- Host: localhost / 127.0.0.1
- Post: 3306

Remeber to set "allowPublicKeyRetrieval" to be TRUE and "useSSL" to be FALSE in _Driver properties_. Follow https://stackoverflow.com/questions/50379839/connection-java-mysql-public-key-retrieval-is-not-allowed for details.
