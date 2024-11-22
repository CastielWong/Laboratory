#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Simple DAG to demonstrate Airflow workflow."""

from datetime import datetime, timedelta
import logging

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
    dag_id="demo_simple",
    description="This is a simple DAG for demo",
    catchup=False,
    max_active_runs=1,
    schedule_interval=timedelta(days=1),
    default_args=default_args,
)

task_a = BashOperator(dag=dag, task_id="task_a", bash_command="echo 123")

task_b = BashOperator(dag=dag, task_id="task_b", bash_command="echo 456")
