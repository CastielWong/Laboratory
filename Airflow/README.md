
- [Docker](#docker)
  - [Docker-compose](#docker-compose)
  - [Common Command](#common-command)
- [Local](#local)
  - [Singleton](#singleton)
  - [Structure](#structure)
- [Reference](#reference)


## Docker

### Docker-compose

1. Start up Airflow via `docker-compose up -d`
1. Go to "localhost:8080" for the UI
1. Find the username and password in "entrypoint.sh"

### Common Command

Common commands when debugging with `docker-compose`:

```sh
# build images first then compose containers
docker-compose up --build -d

# investigate the postgres DB
docker exec -it airflow_postgres psql -U airflow
```

Common commands when debugging with `docker`:

```sh
# create the customized Airflow image locally
docker build -t lab-airflow:demo -f Dockerfile .
# run the customized image
docker run --name demo_af -it lab-airflow:demo bash
# remove the container
docker rm demo_af
```


## Local

Note that the time to scan the DAGs directory is set by `dag_dir_list_interval` in "${AIRFLOW_HOME}/airflow.cfg", for whose default is 300 seconds.

Below lists common commands:
```sh
# test if a task is running as expected
airflow tasks test {dag_name} {task_name} {yyyy}-{mm}-{dd}

# remember to toggle example_bash_operator on
airflow run example_bash_operator runme_0 2015-01-01

# delete a dag
airflow delete_dag {dag_id}
```

### Singleton

Run `docker-compose -f dc_singleton.yml up --build -d` to explore the simple usage of Airflow.


After the DAG "demo_pipeline" finished, check if data has been loaded in SQLite through`sqlite3 /root/airflow/airflow.db`.

Common SQLite commands:
```
.help

.databases
.tables

.quit
```

### Structure

To explore and run a task locally in a container:
```sh
# initialize the database
airflow db init

# start the web sever, whose default port is 8080
airflow webserver -p 8080
# start the scheduler, which is designed to run as a service in an Airflow production environment
# schedule would execute any toggled-on dag when started
airflow scheduler

# create an admin user for airflow
airflow users create \
--username demo --password demo \
--firstname Airflow --lastname Local \
--role Admin --email demo@airflow.org
```


## Reference
- docker-airflow: https://github.com/puckel/docker-airflow
- Airflow Tutorial: https://airflow-tutorial.readthedocs.io/en/latest/about.html
