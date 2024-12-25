#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Read data for verification."""

from colorama import Fore
from pyiceberg.catalog import load_catalog
from pyiceberg.catalog.sql import SqlCatalog
import colorama
import metadata
import util

_SUPPORT_WAYS = ("pyiceberg", "pyspark")


def read_via_pyiceberg(config: str = "s3") -> None:
    """Retrieve data via `pyicerberg`.

    Args:
        config: which configuration to use, ["fs", "s3"]
    """
    if config not in metadata.SPARK_CONFIG.keys():
        print(Fore.RED + f"Configuration for '{config}' is not supported.")
        return

    catalog_name = "optional"  # not mandatory

    db_namespace = metadata.DB_NAMESPACE
    table_name = metadata.TABLE_NAME

    if config == "fs":
        path_storage = "/home/iceberg/warehouse"
        db_fs_name = "pyiceberg_catalog_sqlite.db"
        catalog = SqlCatalog(
            catalog_name,
            **{
                "uri": f"sqlite:///{path_storage}/{db_fs_name}",
                "warehouse": f"file://{path_storage}",
            },
        )
    else:
        catalog = load_catalog(
            catalog_name,
            **{
                "uri": metadata.REST_URL,
                "s3.endpoint": metadata.S3_CONFIG["endpoint"],
                # "s3.access-key-id": metadata.S3_CONFIG["read_access_id"],
                # "s3.secret-access-key": metadata.S3_CONFIG["read_secret_key"],
                "hive.hive2-compatible": True,
            },
        )
    db_table = f"{db_namespace}.{table_name}"

    print(Fore.BLUE + "*" * 100)
    print(Fore.BLUE + "Configuration - PyIceberg")
    print(Fore.BLUE + f"Catalog setting: {catalog.__dict__}")

    print(Fore.BLUE + "*" * 100)
    print(Fore.BLUE + "Configuration - Iceberg")
    print(Fore.BLUE + "List existing namespaces:")
    for ns in catalog.list_namespaces():
        print(
            Fore.BLUE
            + f"Tables in '{ns}' namespace are: \n\t("
            + ",".join(f"'{x[1]}'" for x in catalog.list_tables(ns))
            + ")"
        )

    table = catalog.load_table(db_table)
    print(f"Showing data in '{db_table}'")
    print(table.scan().to_pandas())

    return


def read_via_pyspark(config: str = "fs") -> None:
    """Retrieve data via `pyspark`.

    Args:
        config: which configuration to use, ["fs", "s3"]
    """
    if config == "fs":
        catalog_name = "local"
        # path_storage = "/home/iceberg/warehouse"
    else:
        catalog_name = metadata.CATALOG_NAME

    db_namespace = "db_demo"
    table_name = "sample"

    db_table = f"{db_namespace}.{table_name}"

    print(Fore.BLUE + "*" * 100)
    spark = util.init_spark_session(config)

    print(Fore.BLUE + "Configuration - Spark")
    print(Fore.BLUE + "List catalogs:")
    print(spark.catalog.listCatalogs())
    print(Fore.BLUE + f"Current catalog: {spark.catalog.currentCatalog()}")

    print(Fore.BLUE + "*" * 100)
    print(Fore.BLUE + "Configuration - Iceberg")
    util.print_sql_then_run(spark, "SHOW DATABASES")

    if not spark.catalog.databaseExists(db_namespace):
        print(f"The database {db_namespace} doesn't exist yet")
        return

    util.print_sql_then_run(spark, f"SHOW TABLES IN {catalog_name}.{db_namespace}")

    util.print_sql_then_run(spark, f"SELECT *   FROM {db_table}")  # noqa: S608

    print("*" * 100)

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
        # read_via_pyspark(config="fs")
        read_via_pyspark(config="s3")

    return


if __name__ == "__main__":
    colorama.init(autoreset=True)

    # main(way="pyiceberg")

    main(way="pyspark")
