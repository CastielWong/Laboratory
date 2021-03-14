#!/bin/bash
bash init.sh

# reinitialize Airflow database
airflow db init

# set up default user
airflow users create -u demo -p demo -f John -l Doe -r Admin -e admin@airflow.com

# waiting for metadata table to be initialized
sleep 2

export VARIABLES="${AIRFLOW_HOME}/variables.json"

# import variables
airflow variables import ${VARIABLES}

# start up webserver
airflow webserver
