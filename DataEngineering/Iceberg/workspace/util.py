#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Utility module."""

from colorama import Fore
from pyspark.sql import SparkSession
import metadata

_SPARK_APP = "demo_spark_iceberg"


def enclose_info(func):
    """Place lines in between to enclose the function for readability.

    Args:
        func: function to enclosed
    """

    def wrapper(*args, **kwargs):
        print(Fore.BLUE + "*" * 80)
        res = func(*args, **kwargs)
        print(Fore.BLUE + "*" * 80)
        return res

    return wrapper


def print_sql_then_run(spark: SparkSession, query: str):
    """Run SQL query via Spark.

    Args:
        spark: Spark session to run
        query: SQL query
    """
    print(Fore.CYAN + f"Run SQL '{query}'")
    spark.sql(query).show()
    return


def init_spark_session(config: str = "fs") -> SparkSession:
    """Initialize the Spark session.

    Args:
        config: which configuration to use, ["fs", "s3"]

    Returns:
        A new Spark session
    """
    if config not in metadata.SPARK_CONFIG.keys():
        raise ValueError(f"Configuration for '{config}' is not supported.")

    spark = (
        SparkSession.builder.appName(_SPARK_APP)
        .config(map=metadata.SPARK_CONFIG[config])
        # # enable Hive support
        # .enableHiveSupport()
        .getOrCreate()
    )

    return spark
