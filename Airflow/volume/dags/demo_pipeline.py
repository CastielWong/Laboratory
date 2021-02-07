#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import logging
from datetime import datetime
from datetime import timedelta

from airflow.models import DAG
from airflow.models.taskinstance import TaskInstance
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.http.operators.http import SimpleHttpOperator
from airflow.providers.http.sensors.http import HttpSensor
from airflow.providers.sqlite.operators.sqlite import SqliteOperator
from pandas import json_normalize


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

default_args = {
    "depends_on_past": False,
    "owner": "demo",
    "retries": 2,
    "retry_delay": timedelta(minutes=1),
    "execution_timeout": timedelta(minutes=10),
    "start_date": datetime(2021, 1, 1),
}


def _process_user(ti: TaskInstance) -> None:
    users = ti.xcom_pull(task_ids=["extract_user"])
    if not len(users) or "results" not in users[0]:
        raise ValueError("User is empty")

    user = users[0]["results"][0]
    processed_user = json_normalize(
        {
            "name": f"{user['name']['first']} {user['name']['last']}",
            "country": user["location"]["country"],
        }
    )
    processed_user.to_csv("/tmp/processed_user.csv", index=False, header=False)
    return


dag = DAG(
    dag_id="demo_pipeline",
    description="This is a DAG for demo",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
)

create_table = SqliteOperator(
    dag=dag,
    task_id="create_table",
    sqlite_conn_id="db_sqlite",
    sql="""
        CREATE TABLE IF NOT EXISTS demo (
            name TEXT NOT NULL,
            country TEXt NOT NULL
        );
    """,
)

check_api_available = HttpSensor(
    dag=dag, task_id="check_api_available", http_conn_id="user_api", endpoint="api/",
)

extract_user = SimpleHttpOperator(
    dag=dag,
    task_id="extract_user",
    http_conn_id="user_api",
    endpoint="api/",
    method="GET",
    response_filter=lambda response: json.loads(response.text),
    log_response=True,
)

process_user = PythonOperator(
    dag=dag, task_id="process_user", python_callable=_process_user,
)

store_user = BashOperator(
    dag=dag,
    task_id="store_user",
    bash_command="""
    echo -e '.separator ',' \n.import /tmp/processed_user.csv demo' \
    | sqlite3 /root/airflow/airflow.db
    """,
)

create_table >> check_api_available >> extract_user >> process_user >> store_user
