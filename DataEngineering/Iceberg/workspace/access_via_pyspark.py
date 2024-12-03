#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Access data in Iceberg format via pyspark."""

import shutil

from metadata import (
    CATALOG_NAME,
    DB_NAMESPACE,
    PATH_STORAGE,
    TABLE_NAME,
)
from pyspark.sql import SparkSession
from pyspark.sql.types import DoubleType, LongType, StringType, StructField, StructType
import util

_SPARK_APP = "demo_spark_iceberg"

DATA_SCHEMA = StructType(
    [
        StructField("identifier", LongType(), True),
        StructField("fruit", StringType(), True),
        StructField("price", DoubleType(), True),
    ]
)
SAMPLE_DATA = [
    (1, "Apple", 1.89),
    (2, "Berry", 3.33),
    (3, "Cherry", 2.99),
    (4, "Date", 0.88),
    (5, "Fig", 5.55),
]


def init_spark_session() -> SparkSession:
    """Initialize the Spark session."""
    spark = (
        SparkSession.builder.appName(_SPARK_APP)
        # config
        .config(
            "spark.sql.extensions",
            "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions",
        )
        .config("spark.sql.defaultCatalog", CATALOG_NAME)
        .config(
            "spark.sql.catalog.spark_catalog",
            "org.apache.iceberg.spark.SparkSessionCatalog",
        )
        .config(
            f"spark.sql.catalog.{CATALOG_NAME}", "org.apache.iceberg.spark.SparkCatalog"
        )
        .config(f"spark.sql.catalog.{CATALOG_NAME}.type", "hadoop")
        .config(f"spark.sql.catalog.{CATALOG_NAME}.warehouse", PATH_STORAGE)
        # # configure for Spark authentication
        # .config("spark.authenticate", "true")
        # .config("spark.authenticate.secret", spark_secret_key)
        # .config("spark.authenticate.enableSaslEncryption", "true")
        # # enable Hive support
        # .enableHiveSupport()
        # # set timezone
        # .config("spark.sql.session.timeZone", timezone)
        .getOrCreate()
    )

    return spark


def drop_db(spark: SparkSession, namespace: str) -> None:
    """Drop the database.

    Args:
        spark: spark session
        namespace: database name
    """
    if not spark.catalog.databaseExists(dbName=namespace):
        print(f"There is no database called '{namespace}'")
        return

    print("Before dropping the database")
    list_tables = f"SHOW TABLES IN {namespace}"
    spark.sql(list_tables).show()

    tables = spark.sql(list_tables).collect()
    for table in tables:
        table_name = f"{namespace}.{table.tableName}"
        print(f"dropping table: {table_name}")
        spark.sql(f"DROP TABLE IF EXISTS {table_name}")

    print("After the database is dropped")
    spark.sql(list_tables).show()

    return


def clean_up(spark: SparkSession) -> None:
    """Clean up by deleting database.

    Args:
        spark: spark session
    """
    drop_db(spark=spark, namespace=DB_NAMESPACE)

    shutil.rmtree(f"{PATH_STORAGE}/{DB_NAMESPACE}", ignore_errors=True)

    return


def run_with_spark(spark: SparkSession, db_table: str, choice: str) -> None:
    """Run basic operations using pyspark in either Spark SQL or pure spark.

    Args:
        spark: spark session
        db_table: table name of the database
        choice: either "dataframe" or "sql" way
    """
    if choice not in ("dataframe", "sql"):
        msg = f"{choice} is not supported"
        raise ValueError(msg)

    if choice == "dataframe" and not spark.catalog.tableExists(db_table):
        df = spark.createDataFrame([], DATA_SCHEMA)
        df.writeTo(db_table).create()
    else:
        spark.sql(
            f"""
            CREATE TABLE IF NOT EXISTS {db_table} (
                identifier INT
                , fruit STRING
                , price DOUBLE
            ) USING iceberg
            """
        )

    spark.sql(f"SHOW TABLES IN {CATALOG_NAME}.{DB_NAMESPACE}").show()
    spark.table(db_table).show()

    if choice == "dataframe":
        df = spark.createDataFrame(SAMPLE_DATA, DATA_SCHEMA)
        df.writeTo(db_table).append()
    else:
        insert_data = f"INSERT INTO {db_table} VALUES "  # noqa: S608
        for record in SAMPLE_DATA:
            insert_data += f"{record}, "
        insert_data = f"{insert_data[:-2]};"

        spark.sql(insert_data)

    print("Table after data appended:")
    spark.table(db_table).show()
    return


@util.enclose_info
def main(spark: SparkSession, choice: str = "dataframe", clean: bool = True) -> None:
    """Run the main.

    Args:
        spark: spark session
        choice: either "dataframe" or "sql",
            - "dataframe", pure Python in spark
            - "sql", Spark SQL
        clean: _description_. Defaults to True
    """
    if clean:
        clean_up(spark=spark)

    db_table = f"{DB_NAMESPACE}.{TABLE_NAME}"

    print("Show existing databases")
    spark.sql("SHOW DATABASES").show()
    print(f"Create database '{DB_NAMESPACE}' if not existed")
    spark.sql(f"CREATE DATABASE IF NOT EXISTS {DB_NAMESPACE}")

    run_with_spark(spark=spark, db_table=db_table, choice=choice)

    return


if __name__ == "__main__":
    spark = init_spark_session()

    # clean_up(spark=spark)

    main(spark=spark, choice="dataframe", clean=True)
