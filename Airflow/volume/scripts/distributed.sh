#!/bin/bash

pip install psycopg2-binary --use-deprecated legacy-resolver

# replace sqlite with postgresql
sed -i \
's/sqlite:\/\/\/\/root\/airflow\/airflow.db/postgresql+psycopg2:\/\/postgres:airflow@172.19.0.2\/postgres/g' \
/root/airflow/airflow.cfg
# replace executor
sed -i 's/= SequentialExecutor/= LocalExecutor/g' /root/airflow/airflow.cfg

# reinitialize Airflow database
airflow db init

# set up default user
airflow users create -u demo -p demo -f John -l Doe -r Admin -e admin@airflow.com

# start up webserver and at the background
airflow webserver > /dev/null 2>&1 &
airflow scheduler > /dev/null 2>&1 &

# monitor for commands to keep container running
exec "$@"
