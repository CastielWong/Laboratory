#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Utility module."""

from colorama import Fore
from pyiceberg.catalog import Catalog, load_catalog
from pyspark.sql import SparkSession
import metadata

_PYSPARK_APP = "demo_spark_iceberg"
_PYICEBERG_CATALOG = "optional"  # not mandatory


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


def init_spark_session(storage: str = "fs") -> SparkSession:
    """Initialize the Spark session.

    Args:
        storage: where data is to store, ["fs", "s3"]

    Returns:
        A new Spark session
    """
    if storage not in metadata.PYSPARK_CONFIG.keys():
        raise ValueError(f"Configuration for '{storage}' is not supported.")

    # fmt: off
    spark = (
        SparkSession.builder.appName(_PYSPARK_APP)
        .config(map=metadata.PYSPARK_CONFIG[storage])
        # # enable Hive support
        # .enableHiveSupport()
        .getOrCreate()
    )
    # fmt: on

    return spark


def init_pyiceberg_catalog(storage: str) -> Catalog:
    """Initialize catalog.

    Args:
        storage: where data is to store, ["fs", "s3"]

    Returns:
        Catalog for PyIceberg
    """
    if storage not in metadata.PYICEBERG_CONFIG.keys():
        raise ValueError(f"Configuration for '{storage}' is not supported.")

    catalog = load_catalog(_PYICEBERG_CATALOG, **metadata.PYICEBERG_CONFIG[storage])

    return catalog
