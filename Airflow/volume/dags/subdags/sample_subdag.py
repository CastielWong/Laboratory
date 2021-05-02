#!/usr/bin/env python
# -*- coding: utf-8 -*-
from airflow import DAG
from airflow.operators.bash import BashOperator


def main(parent_dag_id: str, child_dag_id: str, default_args: dict):
    with DAG(
        dag_id=f"{parent_dag_id}.{child_dag_id}", default_args=default_args
    ) as dag:
        BashOperator(
            dag=dag, task_id="task_2", bash_command="sleep 2; echo This is Task 2"
        )
        BashOperator(
            dag=dag, task_id="task_3", bash_command="sleep 2; echo This is Task 3"
        )

        return dag
