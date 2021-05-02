
- [Quick Start](#quick-start)
- [Concept](#concept)
- [Common Command](#common-command)
  - [Docker-compose](#docker-compose)
  - [Docker](#docker)
  - [Airflow](#airflow)
  - [SQLite](#sqlite)
  - [PostgreSQL](#postgresql)
- [Mode](#mode)
  - [Sequential](#sequential)
  - [Parallel](#parallel)
  - [Distributed](#distributed)
- [DAG](#dag)
- [Reference](#reference)


This repo sets up everything for Airflow to run locally.

## Quick Start
1. Start up Airflow via `docker-compose up -d`
1. Go to "localhost:8080" for the UI
1. Find the username and password in "entrypoint.sh"


## Concept
To better maintain the DAG, "Sub DAG" and "Task Group" are two ways for it. However, "Sub DAG" is not recommended for the reasons of its complexity and possible cause of deadlock.


## Common Command
Below is the common commands used for checking or debugging.

### Docker-compose
Change to the directory with corresponding "docker-compose.yml", then:

```sh
# build images first then compose containers
docker-compose up --build -d
# pull down running containers
docker-compose -f {file.yml} down
```

### Docker
```sh
# create the customized Airflow image locally
docker build -t lab-airflow:demo -f Dockerfile .
# run the customized image
docker run --name demo_af -it lab-airflow:demo bash
# remove the container
docker rm demo_af

# investigate the postgres DB
docker exec -it airflow_postgres psql -U airflow
```

### Airflow
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

### SQLite
```bash
sqlite3 airflow/airflow.db

.help

.databases
.tables

.quit
```

### PostgreSQL
```bash
docker exec -it airflow_postgres psql -U postgres

# list database
\l
# list tables
\dt
```


## Mode
Three different modes have been developed for exploration under directory "Compose", for whose images are all developed based on a plain Linux image other than an official Airflow one:
- v_sequential:
  - run with "SequentialExecutor"
  - use sqlite as database
  - the simplest mode, all component works as a whole in singleton
- v_parallel:
  - run with "LocalExecutor" to support parallel running
  - utilize postgres for database
  - have database a separate module
- v_distributed:
  - run with "CeleryExecutor"
  - separate components out to individual modules
  - the most complicated and decoupled model, with two worker instances

To explore how Airflow works, make sure run `docker-compose up -d` under the corresponding directory. Otherwise, docker-compose may not be able to find the correct volume to map.

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

### Sequential
After the DAG "demo_pipeline_sequential" is finished, check if table "random_user" was created and data has been loaded in SQLite. SQLite database should be able to access through `sqlite3 /root/airflow/airflow.db`, then run `SELECT * FROM random_user;` to verify.

### Parallel
Run DAG "demo_pipeline_parallel" to see if everything is working alright. Then check the Gantt chart for the DAG run after finished to verify tasks were able to work parallely.

Apply the "entrypoint.sh" script to replace the executor, then import connections and variables in. The script would launch scheduler and webserver together to set Airflow up and running.

The container would exit automatically if both of the scheduler and webserver are set to be run at the background.

### Distributed
Run DAG "demo_branch" to see if everything is working alright.

Since components are run in individual containers, different component are launched by different command.

Access "localhost:5555" to check the workload for different workers.

## DAG
There are sample dags prepared for exploration:
- "demo_branch":
  - check how the branch Operator and Task Group works
  - note that the tasks after the branch operator must match to the names brancing
- "demo_parallel_subdag":
  - verify if two tasks in a subdag can be ran parallely
  - note that the subdag is very resource-consuming
- "demo_parallel_task_group":
  - verify if two tasks in a Task Group can be ran parallely
  - tasks in Task Group are running much faster than those in subdag
- "demo_parallel":
  - verify if two tasks can be ran parallely
- "demo_sequential":
  - demonstrate a typical sequential pipeline
  - it would only work under Sequential mode, for the reason it uses sqlite
  - Variable and Connection are applied
  - get value from API then process to sqlite
- "demo_simple":
  - simply two unrelated tasks
- "demo_xcom":
  - explore how the xcom helps to pass values between tasks
  - only two values are passed via xcom
  - check "XComs" under "Admin" ti see those passed values

## Reference
- Airflow Tutorial: https://airflow-tutorial.readthedocs.io/en/latest/about.html
- Default official docker-compose file: https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml
