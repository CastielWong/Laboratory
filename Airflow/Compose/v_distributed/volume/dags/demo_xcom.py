#!/usr/bin/env python
# -*- coding: utf-8 -*-
import logging
from datetime import datetime
from datetime import timedelta
from random import randint

from airflow.models import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup


def _return_in_default() -> int:
    value = randint(1, 1000)
    print(f"Value returned: {value}")
    return value


def _return_via_ti(ti) -> None:
    value = randint(1, 1000)
    ti.xcom_push(key="customized_key", value=value)
    print(f"Value pushed to xcom: {value}")
    return


def _pick_out_smallest(ti) -> None:
    values = ti.xcom_pull(
        key="customized_key",
        task_ids=["processing_tasks.task_3", "processing_tasks.task_4"],
    )
    print(f"Values acquired from xcom are: {values}")
    print(f"The smallest value is {min(values)}")

    return


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
    dag_id="demo_xcom",
    description="This is a DAG to demo how x_com works",
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
            dag=dag, task_id="task_2", python_callable=_return_in_default
        )
        task_3 = PythonOperator(
            dag=dag, task_id="task_3", python_callable=_return_via_ti
        )
        task_4 = PythonOperator(
            dag=dag, task_id="task_4", python_callable=_return_via_ti
        )

    task_5 = PythonOperator(
        dag=dag, task_id="task_5", python_callable=_pick_out_smallest
    )

    task_1 >> processing >> task_5
