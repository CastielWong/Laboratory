
- [Docker](#docker)
  - [Docker-compose](#docker-compose)
  - [Common Command](#common-command)
- [Local](#local)
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

To explore and run a task locally in a container,:
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

# remember to toggle example_bash_operator on
airflow run example_bash_operator runme_0 2015-01-01

# delete a dag
airflow delete_dag {dag_id}
```


## Reference
- docker-airflow: https://github.com/puckel/docker-airflow
- Airflow Tutorial: https://airflow-tutorial.readthedocs.io/en/latest/about.html
