#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Access data in Iceberg format via pyiceberg."""

# from pyiceberg.catalog.hive import HiveCatalog
from metadata import (
    DB_NAMESPACE,
    PATH_STORAGE,
    TABLE_NAME,
)
from pyiceberg.catalog.sql import SqlCatalog
from pyiceberg.schema import NestedField, Schema
from pyiceberg.types import DoubleType, LongType, StringType
import pyarrow as pa
import util

# REST_URL = "http://localhost:8181"
LOCAL_CONFIG = {
    "endpoint": "http://minio:9000",
    "access-id": "admin",
    "secret-key": "password",
}

DATA_SCHEMA = Schema(
    NestedField(field_id=1, name="identifier", field_type=LongType(), required=False),
    NestedField(field_id=2, name="fruit", field_type=StringType(), required=False),
    NestedField(field_id=3, name="price", field_type=DoubleType(), required=False),
)
SAMPLE_DATA = pa.Table.from_pylist(
    [
        {"identifier": 1, "fruit": "Apple", "price": 1.89},
        {"identifier": 2, "fruit": "Berry", "price": 3.33},
        {"identifier": 3, "fruit": "Cherry", "price": 2.99},
        {"identifier": 4, "fruit": "Date", "price": 0.88},
        {"identifier": 5, "fruit": "Fig", "price": 5.55},
    ]
)

CATALOG_NAME = "default"
WH_SQLITE = PATH_STORAGE
DIR_NAMESPACE = "ns_sqlite"


def init_catalog():
    """Initialize catalog."""
    catalog = SqlCatalog(
        CATALOG_NAME,
        **{
            "uri": f"sqlite:///{WH_SQLITE}/pyiceberg_catalog_sqlite.db",
            "warehouse": f"file://{WH_SQLITE}",
        },
    )

    # catalog = load_catalog(
    #     CATALOG_NAME,
    #     **{
    #         "uri": REST_URL,
    #         "s3.endpoint": LOCAL_CONFIG["endpoint"],
    #         "s3.access-key-id": LOCAL_CONFIG["access-id"],
    #         "s3.secret-access-key": LOCAL_CONFIG["secret-key"],

    #         # "hive.hive2-compatible": True,
    #     }
    # )

    return catalog


def clean_up(catalog):
    """Clean up by deleting database.

    Args:
        catalog: the catalog
    """
    db_table = f"{DB_NAMESPACE}.{TABLE_NAME}"

    print(f"Dropping table '{db_table}'")
    catalog.purge_table(identifier=db_table)

    print(f"Dropping namespace '{db_table}'")
    catalog.drop_namespace(namespace=DB_NAMESPACE)

    return


def run_with_pyiceberg(catalog, namespace: str, table_name: str) -> None:
    """Run basic operations using pyiceberg.

    Args:
        catalog: the catalog
        namespace: name of database
        table_name: name of table
    """
    db_table = f"{namespace}.{table_name}"

    # create namespace
    if namespace not in (x[0] for x in catalog.list_namespaces()):
        print(f"Creating namespace '{namespace}'")
        catalog.create_namespace(namespace)

    # create table
    print(f"Tables in '{namespace}' are: {catalog.list_tables(namespace)}")
    if table_name not in (x[1] for x in catalog.list_tables(namespace)):
        print(f"Creating table '{table_name}'")
        catalog.create_table(
            db_table,
            schema=DATA_SCHEMA,
            location=f"{WH_SQLITE}/{DIR_NAMESPACE}",
        )

    # append data
    table = catalog.load_table(db_table)
    table.append(SAMPLE_DATA)
    print(f"Showing data in '{db_table}'")
    print(table.scan().to_pandas())

    return


@util.enclose_info
def main(catalog) -> None:
    """Run the main.

    Args:
        catalog: the catalog
    """
    print("List existing namespaces:")
    for ns in catalog.list_namespaces():
        print(ns)

    run_with_pyiceberg(catalog=catalog, namespace=DB_NAMESPACE, table_name=TABLE_NAME)

    return


if __name__ == "__main__":
    catalog = init_catalog()

    # clean_up(catalog=catalog)

    main(catalog=catalog)
