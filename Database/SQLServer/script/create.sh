#!/usr/bin/bash

DB_NAME='DemoDB'

/opt/mssql-tools/bin/sqlcmd -l 120 -S localhost -U ${SA_USER} -P ${SA_PASSWORD} \
    -Q "CREATE DATABASE ${DB_NAME};"

/opt/mssql-tools/bin/sqlcmd -l 120 -S localhost -U ${SA_USER} -P ${SA_PASSWORD} \
    -d ${DB_NAME} \
    -i ${DIR_CONFIG}/schemas.sql \
    -i ${DIR_CONFIG}/tables.sql
