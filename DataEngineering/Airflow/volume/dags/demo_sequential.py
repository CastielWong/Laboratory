#!/usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
import json
import logging

from airflow.models import DAG, Variable
from airflow.models.taskinstance import TaskInstance
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.http.operators.http import SimpleHttpOperator
from airflow.providers.http.sensors.http import HttpSensor
from airflow.providers.sqlite.operators.sqlite import SqliteOperator
from pandas import json_normalize

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

_PATH_DB = "/root/airflow/airflow.db"
_TABLE_NAME = "random_user"
_API_NAME = "user_generation_api"
_PATH_DATA_TEMP = "/tmp/processed_user.csv"

default_args = {
    "depends_on_past": False,
    "owner": "demo",
    "retries": 2,
    "retry_delay": timedelta(minutes=1),
    "execution_timeout": timedelta(minutes=10),
    "start_date": datetime(2021, 1, 1),
}


def _process_user(ti: TaskInstance) -> None:
    """Process user from JSON and save as csv.

    Args:
        ti: the task instance
    """
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
    processed_user.to_csv(_PATH_DATA_TEMP, index=False, header=False)
    return


dag = DAG(
    dag_id="demo_pipeline_sequential",
    description="This is a DAG to demo sequential pipeline",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
)


start = Variable.get(key="start", default_var="starting point")
end = Variable.get(key="end", default_var="ending point")

start_point = BashOperator(
    dag=dag, task_id="start_point", bash_command=f"echo '{start}'"
)
end_point = BashOperator(dag=dag, task_id="end_point", bash_command=f"echo '{end}'")


create_table = SqliteOperator(
    dag=dag,
    task_id="create_table",
    sqlite_conn_id="db_sqlite",
    sql=f"""
        CREATE TABLE IF NOT EXISTS {_TABLE_NAME} (
            name TEXT NOT NULL,
            country TEXt NOT NULL
        );
    """,
)

check_api_available = HttpSensor(
    dag=dag,
    task_id="check_api_available",
    http_conn_id=_API_NAME,
    endpoint="api/",
)

extract_user = SimpleHttpOperator(
    dag=dag,
    task_id="extract_user",
    http_conn_id=_API_NAME,
    endpoint="api/",
    method="GET",
    response_filter=lambda response: json.loads(response.text),
    log_response=True,
)

process_user = PythonOperator(
    dag=dag,
    task_id="process_user",
    python_callable=_process_user,
)

store_user = BashOperator(
    dag=dag,
    task_id="store_user",
    bash_command=f"""
    echo -e '.separator ',' \n.import {_PATH_DATA_TEMP} {_TABLE_NAME}' \
    | sqlite3 {_PATH_DB}
    """,
)


(
    start_point
    >> create_table  # noqa: W503
    >> check_api_available  # noqa: W503
    >> extract_user  # noqa: W503
    >> process_user  # noqa: W503
    >> store_user  # noqa: W503
    >> end_point  # noqa: W503
)
