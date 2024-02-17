# -*- coding: utf-8 -*-
"""Demo DAG for Sub-DAG."""
from __future__ import annotations

from datetime import datetime
import os
import sys

from airflow import DAG
# from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import ExternalPythonOperator, PythonOperator
from airflow.operators.subdag import SubDagOperator

_DAG_ID = os.path.basename(__file__).replace(".py", "")

PATH_TO_PYTHON_BINARY = sys.executable


def push_config_values_to_xcom(**kwargs):
    """Push "source_date" value from XCOM.

    When there is no input "source_date", push a default value instead.

    Returns:
        Value of "source_date" via XCOM
    """
    return kwargs["dag_run"].conf.get("source_date", "default_value")


def read_xcom(ti, xcom_task):
    """Read value from XCOM.

    Args:
        ti: task instance
        xcom_task: id of the task

    Returns:
        The return XCOM value from the task
    """
    return_value = ti.xcom_pull(
        dag_id=_DAG_ID,
        task_ids=xcom_task,
        key="return_value",
        include_prior_dates=True,
    )
    print("-" * 100)
    print(f"Check TaskInstance: {ti}")
    print(f"Value retrieved from xcom: '{return_value}'")
    print("-" * 100)

    return return_value


def generate_sub_dag(dag_id, xcom_task, args) -> DAG:
    """Generate a Sub-DAG.

    Args:
        dag_id: ID assigned for the Sub-DAG
        xcom_task: task ID of the XCOM value to retrieve
        args: arguments passed in

    Returns:
        A DAG properly defined
    """

    def printing(msg: str):
        print(f"This is the sample printing:\t'{msg}'")
        return f"return_{msg}"

    sub_dag = DAG(
        dag_id=dag_id,
        default_args=args,
        start_date=datetime(2024, 1, 1),
        catchup=False,
        schedule="@daily",
    )

    start = EmptyOperator(dag=sub_dag, task_id="start")

    check_xcom_value = PythonOperator(
        dag=sub_dag,
        task_id="check_xcom_value",
        python_callable=read_xcom,
        op_kwargs={"xcom_task": xcom_task},
    )

    print_value = ExternalPythonOperator(
        dag=sub_dag,
        task_id="print_value",
        default_args=args,
        python=PATH_TO_PYTHON_BINARY,
        python_callable=printing,
        op_kwargs={"msg": check_xcom_value.output},
    )

    end = EmptyOperator(dag=sub_dag, task_id="end")

    start >> check_xcom_value >> print_value >> end
    return sub_dag


with DAG(
    dag_id=_DAG_ID,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    schedule="@daily",
) as dag:
    begin = EmptyOperator(dag=dag, task_id="begin")

    setup_xcom = PythonOperator(
        dag=dag,
        task_id="setup_xcom",
        python_callable=push_config_values_to_xcom,
    )

    sub_dags = []
    sub_dag_prefix = "check_subdag"
    for i in range(1, 3):
        sub_dag_name = f"{sub_dag_prefix}_{i}"

        subdag = generate_sub_dag(
            dag_id=f"{dag.dag_id}.{sub_dag_name}",
            xcom_task=setup_xcom.task_id,
            args=dag.default_args,
        )

        check_subdag = SubDagOperator(
            dag=dag,
            task_id=sub_dag_name,
            subdag=subdag,
        )
        sub_dags.append(check_subdag)

    finish = EmptyOperator(dag=dag, task_id="finish")

    begin >> setup_xcom >> sub_dags >> finish
