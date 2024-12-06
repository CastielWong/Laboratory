#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Read data for verification."""

from pyiceberg.catalog import load_catalog
from pyspark.sql import SparkSession

_SUPPORT_WAYS = ("pyiceberg", "pyspark")

_SPARK_APP = "demo_spark_iceberg"

IP_REST = "181.4.11.11"


def read_via_pyiceberg() -> None:
    """Retrieve data via `pyicerberg`."""
    catalog_name = "default"
    # path_storage = "/home/iceberg/warehouse"
    # db_fs_name = "pyiceberg_catalog_sqlite.db"

    s3_config = {
        "endpoint": "http://minio:9000",
        "access-id": "admin",
        "secret-key": "password",
    }

    db_namespace = "db_demo"
    table_name = "sample"

    # catalog = SqlCatalog(
    #     catalog_name,
    #     **{
    #         "uri": f"sqlite:///{path_storage}/{db_fs_name}",
    #         "warehouse": f"file://{path_storage}",
    #     },
    # )
    catalog = load_catalog(
        catalog_name,
        **{
            "uri": f"http://{IP_REST}:8181",
            "s3.endpoint": s3_config["endpoint"],
            "s3.access-key-id": s3_config["access-id"],
            "s3.secret-access-key": s3_config["secret-key"],
            "hive.hive2-compatible": True,
        },
    )
    db_table = f"{db_namespace}.{table_name}"

    print("List existing namespaces:")
    for ns in catalog.list_namespaces():
        print(ns)

    table = catalog.load_table(db_table)
    print(f"Showing data in '{db_table}'")
    print(table.scan().to_pandas())

    return


def read_via_pyspark() -> None:
    """Retrieve data via `pyspark`."""
    catalog_name = "local"
    # path_storage = "/home/iceberg/warehouse"

    db_namespace = "db_demo"
    table_name = "sample"

    db_table = f"{db_namespace}.{table_name}"

    # conf_hadoop = {
    #     # config for using iceberg standardized zone datalake
    #     "spark.sql.extensions": "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions",  # noqa: E501
    #     "spark.sql.catalog.spark_catalog": "org.apache.iceberg.spark.SparkSessionCatalog",  # noqa: E501
    #     "spark.sql.defaultCatalog": catalog_name,
    #     f"spark.sql.catalog.{catalog_name}": "org.apache.iceberg.spark.SparkCatalog",
    #     f"spark.sql.catalog.{catalog_name}.type": "hadoop",
    #     f"spark.sql.catalog.{catalog_name}.warehouse": path_storage,
    # }
    conf_s3 = {
        "spark.sql.extensions": "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions",  # noqa: E501
        "spark.sql.defaultCatalog": catalog_name,
        f"spark.sql.catalog.{catalog_name}": "org.apache.iceberg.spark.SparkCatalog",
        f"spark.sql.catalog.{catalog_name}.type": "hive",
        f"spark.sql.catalog.{catalog_name}.warehouse": "s3a://warehouse/",
        f"spark.sql.catalog.{catalog_name}.io-impl": "org.apache.iceberg.aws.s3.S3FileIO",  # noqa: E501
    }

    spark = (
        SparkSession.builder.appName(_SPARK_APP)
        .config(map=conf_s3)
        # # enable Hive support
        # .enableHiveSupport()
        # # set timezone
        # .config("spark.sql.session.timeZone", timezone)
        .getOrCreate()
    )

    print("List catalogs:")
    print(spark.catalog.listCatalogs())

    query = f"SHOW TABLES IN {catalog_name}.{db_namespace}"
    print(f"Run SQL '{query}'")
    spark.sql(query).show()

    print(f"Data inside table '{db_table}':")
    spark.table(db_table).show()

    return


def main(way: str = "pyiceberg") -> None:
    """Run the main.

    Args:
        way: the way to retrieve the data, support 'pyiceberg' and 'pyspark' only

    Raises:
        ValueError: when it's an unsupported value
    """
    if way not in _SUPPORT_WAYS:
        raise ValueError(f"{way} is not supported, please go with {_SUPPORT_WAYS}")

    if way == "pyiceberg":
        read_via_pyiceberg()
    elif way == "pyspark":
        read_via_pyspark()

    return


if __name__ == "__main__":
    main(way="pyiceberg")

    # main(way="pyspark")
