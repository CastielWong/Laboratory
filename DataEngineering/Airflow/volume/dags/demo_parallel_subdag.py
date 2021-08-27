#!/usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
import logging

from airflow.models import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.subdag import SubDagOperator
from subdags import sample_subdag

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DAG_ID = "demo_pipeline_parallel_subdag"

default_args = {
    "depends_on_past": False,
    "owner": "demo",
    "retries": 2,
    "retry_delay": timedelta(minutes=1),
    "execution_timeout": timedelta(minutes=10),
    "start_date": datetime(2021, 1, 1),
}


with DAG(
    dag_id=DAG_ID,
    description="This is a DAG demo for how to use sub DAG",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
) as dag:
    task_1 = BashOperator(
        dag=dag, task_id="task_1", bash_command="sleep 2; echo This is Task 1"
    )

    processing = SubDagOperator(
        task_id="processing_tasks",
        subdag=sample_subdag.main(DAG_ID, "processing_tasks", default_args),
    )

    task_4 = BashOperator(
        dag=dag, task_id="task_4", bash_command="sleep 2; echo This is Task 4"
    )

    task_1 >> processing >> task_4
