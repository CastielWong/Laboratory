#!/usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
import logging

from airflow.models import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.task_group import TaskGroup

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
    dag_id="demo_pipeline_parallel_task_group",
    description="This is a DAG demo for how to use Task Group",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
) as dag:
    task_1 = BashOperator(
        dag=dag, task_id="task_1", bash_command="sleep 2; echo This is Task 1"
    )

    with TaskGroup("processing_tasks") as processing:
        task_2 = BashOperator(
            dag=dag, task_id="task_2", bash_command="sleep 2; echo This is Task 2"
        )

        # embed task group deeper
        with TaskGroup("spark_tasks") as spark_tasks:
            task_3_1 = BashOperator(
                dag=dag,
                task_id="task_3_1",
                bash_command="sleep 2; echo This is Task 3_1 for Spark",
            )
            task_3_2 = BashOperator(
                dag=dag,
                task_id="task_3_2",
                bash_command="sleep 2; echo This is Task 3_2 for Spark",
            )
        with TaskGroup("flink_tasks") as flink_tasks:
            task_3_1 = BashOperator(
                dag=dag,
                task_id="task_3_1",
                bash_command="sleep 2; echo This is Task 3_1 for Flink",
            )
            task_3_2 = BashOperator(
                dag=dag,
                task_id="task_3_2",
                bash_command="sleep 2; echo This is Task 3_2 for Flink",
            )

    task_4 = BashOperator(
        dag=dag, task_id="task_4", bash_command="sleep 2; echo This is Task 4"
    )

    task_1 >> processing >> task_4
