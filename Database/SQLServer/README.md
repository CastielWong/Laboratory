
"Makefile" is used to automate the build:
- `make start`: start a brand new SQL Server
- `make init`: start a new SQL Server with sample database
- `make stop`: tear up the instance
- `make query SQL={sql}`: run sql query, e.g. `make query SQL='SELECT COUNT(*) FROM DemoDB.dummy.source'`


## Reference
- `sqlcmd` syntax: https://learn.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver16#syntax
