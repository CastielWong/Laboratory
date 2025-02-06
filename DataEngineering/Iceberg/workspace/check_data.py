#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Read data for verification."""

from colorama import Fore
import colorama
import metadata
import util

_SUPPORT_WAYS = ("pyiceberg", "pyspark")


def read_via_pyiceberg(data_source: str) -> None:
    """Retrieve data via `pyicerberg`.

    Args:
        data_source: the data source to read, ["fs", "s3"]
    """
    if data_source not in metadata.PYICEBERG_CONFIG.keys():
        print(Fore.RED + f"Data source '{data_source}' is not supported.")
        return

    catalog = util.init_pyiceberg_catalog(storage=data_source)

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

    db_table = f"{metadata.DB_NAMESPACE}.{metadata.TABLE_NAME}"
    table = catalog.load_table(db_table)
    print(f"Showing data in '{db_table}'")
    print(table.scan().to_pandas())

    return


def read_via_pyspark(data_source: str) -> None:
    """Retrieve data via `pyspark`.

    Args:
        data_source: the data source to read, ["fs", "s3"]
    """
    if data_source not in metadata.PYSPARK_CONFIG.keys():
        print(Fore.RED + f"Data source '{data_source}' is not supported.")
        return

    if data_source == "fs":
        catalog_name = "local"
        # path_storage = "/home/iceberg/warehouse"
    else:
        catalog_name = metadata.CATALOG_NAME

    db_namespace = "db_demo"
    table_name = "sample"

    db_table = f"{db_namespace}.{table_name}"

    print(Fore.BLUE + "*" * 100)
    spark = util.init_spark_session(storage=data_source)

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


def main(way: str, data_source: str) -> None:
    """Run the main.

    Args:
        way: the way to retrieve the data, support 'pyiceberg' and 'pyspark' only
        data_source: the data source, ["fs", "s3"]

    Raises:
        ValueError: when it's an unsupported value
    """
    if way not in _SUPPORT_WAYS:
        raise ValueError(f"{way} is not supported, please go with {_SUPPORT_WAYS}")

    if way == "pyiceberg":
        read_via_pyiceberg(data_source=data_source)
    elif way == "pyspark":
        read_via_pyspark(data_source=data_source)

    return


if __name__ == "__main__":
    approach = metadata.APPROACH

    colorama.init(autoreset=True)

    print(Fore.BLUE + f"Approach: {metadata.APPROACH}\nMode: {metadata.STORAGE}")
    main(way=approach, data_source=metadata.STORAGE)
