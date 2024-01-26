#!/usr/bin/bash

DB_NAME='DemoDB'

/opt/mssql-tools/bin/sqlcmd -l 120 -S localhost -U ${SA_USER} -P ${SA_PASSWORD} -Q "$1"
