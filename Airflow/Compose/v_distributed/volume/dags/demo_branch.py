#!/usr/bin/env python
# -*- coding: utf-8 -*-
import logging
from datetime import datetime
from datetime import timedelta
from random import randint

from airflow.models import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import BranchPythonOperator
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup


def _generate_value(ti) -> None:
    value = randint(1, 1000)
    ti.xcom_push(key="generated_value", value=value)
    print(f"Value pushed to xcom: {value}")
    return


def _check_top_quarter(ti) -> str:
    top_quarter_boundary = 750

    values = ti.xcom_pull(
        key="generated_value",
        task_ids=[
            "processing_tasks.task_2",
            "processing_tasks.task_3",
            "processing_tasks.task_4",
        ],
    )
    print(f"Values acquired from xcom are: {values}")

    # note that the returned result would need to match its following task id
    results = []
    if max(values) > top_quarter_boundary:
        results.append("top_quarter")
    if min(values) <= top_quarter_boundary:
        results.append("normal")

    print(f"The branching is: {results}")
    return results


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

with DAG(
    dag_id="demo_branch",
    description="This is a DAG to demo how the pipeline branches",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
) as dag:
    task_1 = BashOperator(
        dag=dag,
        task_id="task_1",
        do_xcom_push=False,
        bash_command="sleep 2; echo This is Task 1",
    )

    with TaskGroup("processing_tasks") as processing:
        task_2 = PythonOperator(
            dag=dag, task_id="task_2", python_callable=_generate_value
        )
        task_3 = PythonOperator(
            dag=dag, task_id="task_3", python_callable=_generate_value
        )
        task_4 = PythonOperator(
            dag=dag, task_id="task_4", python_callable=_generate_value
        )

    check_top_quarter = BranchPythonOperator(
        task_id="check_top_quarter", python_callable=_check_top_quarter
    )

    top_quarter = DummyOperator(task_id="top_quarter")
    normal = DummyOperator(task_id="normal")

    task_1 >> processing >> check_top_quarter >> [top_quarter, normal]
