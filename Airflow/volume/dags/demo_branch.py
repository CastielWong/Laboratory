#!/usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
from random import randint
from typing import List
import logging

from airflow.models import DAG, TaskInstance
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import BranchPythonOperator, PythonOperator
from airflow.utils.task_group import TaskGroup

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

default_args = {
    "depends_on_past": False,
    "owner": "demo",
    "retries": 2,
    "retry_delay": timedelta(seconds=3),
    "execution_timeout": timedelta(minutes=10),
    "start_date": datetime(2021, 1, 1),
}


def _generate_value(ti: TaskInstance) -> None:
    """Generate value between 1 and 1_000, inclusive.

    Args:
        ti: the task instance
    """
    value = randint(1, 1_000)
    ti.xcom_push(key="generated_value", value=value)
    print(f"Value pushed to xcom: {value}")
    return


def _check_top_quarter(ti: TaskInstance) -> List[str]:
    """Check if values generated randomly exceed 800 or not.

    Args:
        ti: the task instance

    Returns:
        List of names for its following branching tasks
    """
    top_quarter_boundary = 800

    values = ti.xcom_pull(
        key="generated_value",
        task_ids=[
            "processing_tasks.task_1",
            "processing_tasks.task_2",
            "processing_tasks.task_3",
        ],
    )
    print(f"Values acquired from xcom are: {values}")

    # note that the returned result must to match its following task id
    results = []
    if max(values) > top_quarter_boundary:
        results.append("include_top")
    if min(values) <= top_quarter_boundary:
        results.append("include_normal")

    print(f"The branching is: {results}")
    return results


with DAG(
    dag_id="demo_branch",
    description="This is a DAG to demo how the pipeline branches",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
) as dag:
    start_point = BashOperator(
        dag=dag,
        task_id="start_point",
        do_xcom_push=False,
        bash_command="sleep 2; echo 'This is the start point'",
    )

    with TaskGroup("processing_tasks") as processing:
        task_1 = PythonOperator(
            dag=dag, task_id="task_1", python_callable=_generate_value
        )
        task_2 = PythonOperator(
            dag=dag, task_id="task_2", python_callable=_generate_value
        )
        task_3 = PythonOperator(
            dag=dag, task_id="task_3", python_callable=_generate_value
        )

    check_top_quarter = BranchPythonOperator(
        task_id="check_top_quarter", python_callable=_check_top_quarter
    )

    include_top = DummyOperator(task_id="include_top")
    include_normal = DummyOperator(task_id="include_normal")

    task_to_fail = BashOperator(dag=dag, task_id="task_to_fail", bash_command="exit 1")

    complete_all_branch = BashOperator(
        dag=dag,
        task_id="complete_all_branch",
        bash_command="exit 0",
        trigger_rule="none_skipped",
    )

    detect_success = BashOperator(
        dag=dag,
        task_id="detect_success",
        bash_command="exit 0",
        trigger_rule="one_success",
    )

    detect_failed = BashOperator(
        dag=dag,
        task_id="detect_failed",
        bash_command="exit 0",
        trigger_rule="one_failed",
    )

    start_point >> processing >> check_top_quarter
    check_top_quarter >> [include_top, include_normal] >> complete_all_branch
    [complete_all_branch, task_to_fail] >> detect_success
    [complete_all_branch, task_to_fail] >> detect_failed
