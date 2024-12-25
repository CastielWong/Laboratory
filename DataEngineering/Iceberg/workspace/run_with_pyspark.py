#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Access data in Iceberg format via pyspark."""

import shutil

from pyspark.sql import SparkSession
import metadata
import util

_SPARK_APP = "demo_spark_iceberg"


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
    drop_db(spark=spark, namespace=metadata.DB_NAMESPACE)

    shutil.rmtree(
        f"{metadata.FS_LOCAL_PATH}/{metadata.DB_NAMESPACE}", ignore_errors=True
    )

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
        df = spark.createDataFrame([], metadata.PYSPARK_DATA_SCHEMA)
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

    spark.sql(f"SHOW TABLES IN {metadata.CATALOG_NAME}.{metadata.DB_NAMESPACE}").show()
    spark.table(db_table).show()

    if choice == "dataframe":
        # not iceberg format?
        df = spark.createDataFrame(
            metadata.PYSPARK_SAMPLE_DATA, metadata.PYSPARK_DATA_SCHEMA
        )
        df.writeTo(db_table).append()
    else:
        insert_data = f"INSERT INTO {db_table} VALUES "  # noqa: S608
        for record in metadata.PYSPARK_SAMPLE_DATA:
            insert_data += f"{record}, "
        insert_data = f"{insert_data[:-2]};"

        spark.sql(insert_data)

    print("Table after data appended:")
    spark.table(db_table).show()
    return


@util.enclose_info
def main(spark: SparkSession, choice: str = "dataframe") -> None:
    """Run the main.

    Args:
        spark: spark session
        choice: either "dataframe" or "sql",
            - "dataframe", pure Python in spark
            - "sql", Spark SQL
    """
    db_table = f"{metadata.DB_NAMESPACE}.{metadata.TABLE_NAME}"

    print("Show existing databases")
    spark.sql("SHOW DATABASES").show()
    print(f"Create database '{metadata.DB_NAMESPACE}' if not existed")
    spark.sql(f"CREATE DATABASE IF NOT EXISTS {metadata.DB_NAMESPACE}")

    run_with_spark(spark=spark, db_table=db_table, choice=choice)

    return


if __name__ == "__main__":
    # spark = init_spark_session(config="fs")
    spark = init_spark_session(config="s3")

    print("=" * 100)
    print("Displaying the version of Iceberg:")
    spark.sql("SELECT iceberg_version()").show()

    main(spark=spark, choice="sql")

    # clean_up(spark=spark)
