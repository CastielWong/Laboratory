# -*- coding: utf-8 -*-
"""Demo DAG for sensors."""
from __future__ import annotations

from datetime import datetime
import os

# from airflow.decorators import task
from airflow.models import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.sftp.sensors.sftp import SFTPSensor
# from airflow.providers.ssh.operators.ssh import SSHOperator
from airflow.sensors.time_sensor import TimeSensor
from airflow.sensors.python import PythonSensor
import pendulum

_DAG_ID = os.path.basename(__file__).replace(".py", "")

_TIMEZONE = "Asia/Chongqing"
# host: ftp.xxx.com
# port: 22
# user: dummy
# password: dummy
# or extra: {"key_file": "/opt/airflow/dags/xxx.pem"}
_SFTP_CONNECTION = "demo-sftp"


def wait_until_condition(count: int) -> bool:
    """Wait until the count of second reached.

    Args:
        count: dummy parameter,

    Returns:
        True if the second reach to the specified condition
    """
    second = pendulum.now(tz=_TIMEZONE).second
    print(f"Current second is {second} \tCount is {count}")
    return second >= 50


with DAG(
    _DAG_ID,
    schedule="@once",
    start_date=pendulum.datetime(2024, 2, 1, tz=_TIMEZONE),
    catchup=False,
    tags=["example", "sftp"],
) as dag:
    target_file = "/root/dir/data.csv"

    today = pendulum.today(tz=_TIMEZONE)
    check_dt_str = today.add(hours=9, minutes=30).isoformat()
    check_time = datetime.fromisoformat(check_dt_str).time()

    wait_till = TimeSensor(
        dag=dag,
        task_id="wait_till",
        target_time=check_time,
        poke_interval=30,
    )

    wait_for_condition = PythonSensor(
        dag=dag,
        task_id="wait_for_condition",
        poke_interval=5,
        python_callable=wait_until_condition,
        # as the task is defined beforehand,
        # function is needed to call for dynamic assignment
        op_kwargs={
            "count": 100,
        },
    )

    check_time_sensor = BashOperator(
        dag=dag,
        task_id="check_time_sensor",
        bash_command="echo 'time sensor reached'",
    )

    poke_sftp = SFTPSensor(
        task_id="poke_sftp",
        path=target_file,
        poke_interval=10,
        timeout=30,
        sftp_conn_id=_SFTP_CONNECTION,
    )

    poke_sftp_files = SFTPSensor(
        task_id="poke_sftp_files",
        path=os.path.dirname(target_file),
        file_pattern="*.csv",
        poke_interval=10,
        timeout=30,
        sftp_conn_id=_SFTP_CONNECTION,
    )

    wait_till >> wait_for_condition >> check_time_sensor >> poke_sftp

    poke_sftp_files
