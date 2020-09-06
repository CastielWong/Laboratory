
This is used to explore Airflow.

## Docker

Run `docker pull puckel/docker-airflow:1.10.9` to pull the Airflow image.

1. `docker run -d -p 8080:8080 puckel/docker-airflow:1.10.9 webserver`
1. Go to "localhost:8080" for the UI


## Pip

To run a task, move to current directory then:
```sh
pip install apache-airflow

# set the airflow home to specified directory
export AIRFLOW_HOME=${PWD}/demo

# initialize the database
airflow initdb

# start the web sever, whose default port is 8080
airflow webserver -p 8080
# start the scheduler, which is designed to run as a service in an Airflow production environment
# schedule would execute any toggled-on dag when started
airflow scheduler

# remember to toggle example_bash_operator on
airflow run example_bash_operator runme_0 2015-01-01

# delete a dag
airflow delete_dag {dag_id}
```


## Reference
- docker-airflow: https://github.com/puckel/docker-airflow
