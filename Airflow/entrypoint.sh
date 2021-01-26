#!/bin/sh

export AIRFLOW_HOME=/opt/airflow

export AIRFLOW_USERNAME="demo"
export AIRFLOW_PASSWORD="demo"
export AIRFLOW_SMTP_MAIL_FROM="demo@airflow.org"


# perform corresponding action by checking the first parameter passed to the script
if [ "$1" = "webserver" ]; then
    # initialize db when running as web server
    airflow db init
    # airflow 2.0 requries an admin user to be created
    airflow users create \
    --username ${AIRFLOW_USERNAME} --password ${AIRFLOW_PASSWORD} \
    --firstname Airflow --lastname Local \
    --role Admin --email ${AIRFLOW_SMTP_MAIL_FROM}

    exec airflow "$@"
fi
