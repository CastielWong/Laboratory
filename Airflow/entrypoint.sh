#!/bin/sh

export AIRFLOW_USERNAME="demo"
export AIRFLOW_PASSWORD="demo"
export AIRFLOW_SMTP_MAIL_FROM="airflow@example.com"


# perform corresponding action by checking the first parameter passed to the script
if [ "$1" = "webserver" ]; then
    # initialize db when running as web server
    airflow db init
    # airflow 2.0 requries an admin user to be created
    airflow users create \
    --username ${AIRFLOW_USERNAME} --password ${AIRFLOW_PASSWORD} \
    --firstname Airflow --lastname Local \
    --role Admin --email ${AIRFLOW_SMTP_MAIL_FROM}

    exec airflow webserver
else
    # wait for the database to be initialized
    sleep 8

    if [ "$1" = "scheduler" ]; then
        exec airflow scheduler
    elif [ "$1" = "flower" ]; then
        exec airflow celery flower
    elif [ "$1" = "worker" ]; then
        exec airflow celery worker
    fi
fi
