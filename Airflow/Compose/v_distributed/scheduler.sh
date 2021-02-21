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


airflow scheduler

# monitor for commands to keep container running
exec "$@"
