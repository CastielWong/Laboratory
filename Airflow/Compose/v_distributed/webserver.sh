#!/bin/bash
pip install --use-deprecated legacy-resolver \
    "psycopg2-binary" \
    "apache-airflow[celery,postgres]" \
    "redis"

# replace sqlite with postgresql, make sure the private IP is set up correctly
sed -i \
's/sqlite:\/\/\/\/root\/airflow\/airflow.db/postgresql+psycopg2:\/\/postgres:airflow@172.20.0.2:5432\/airflow/g' \
/root/airflow/airflow.cfg
# replace executor
sed -i 's/= SequentialExecutor/= CeleryExecutor/g' /root/airflow/airflow.cfg
# update redis
sed -i 's/= redis:\/\/redis:6379/= redis:\/\/172.20.0.3:6379/g' /root/airflow/airflow.cfg
# update result_backend
sed -i \
's/= db+postgresql:\/\/postgres:airflow@postgres\/airflow/db+postgresql:\/\/postgres:airflow@172.20.0.2:5432\/airflow/g' \
/root/airflow/airflow.cfg

# reinitialize Airflow database
airflow db init

# set up default user
airflow users create -u demo -p demo -f John -l Doe -r Admin -e admin@airflow.com

# waiting for metadata table to be initialized
sleep 2

export VARIABLES="${AIRFLOW_HOME}/variables.json"

# import variables
airflow variables import ${VARIABLES}

# start up scheduler at the background
airflow scheduler > /dev/null 2>&1 &
airflow webserver
