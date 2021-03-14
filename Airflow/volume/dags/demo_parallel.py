#!/usr/bin/env python
# -*- coding: utf-8 -*-
import logging
from datetime import datetime
from datetime import timedelta

from airflow.models import DAG
from airflow.operators.bash import BashOperator

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

dag = DAG(
    dag_id="demo_pipeline_parallel",
    description="This is a DAG for simple demo in pipeline",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
)

task_1 = BashOperator(
    dag=dag, task_id="task_1", bash_command="sleep 2; echo This is Task 1"
)
task_2 = BashOperator(
    dag=dag, task_id="task_2", bash_command="sleep 2; echo This is Task 2"
)
task_3 = BashOperator(
    dag=dag, task_id="task_3", bash_command="sleep 2; echo This is Task 3"
)
task_4 = BashOperator(
    dag=dag, task_id="task_4", bash_command="sleep 2; echo This is Task 4"
)

task_1 >> [task_2, task_3] >> task_4
