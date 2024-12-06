#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Access data in Iceberg format via pyiceberg."""

# from pyiceberg.catalog.hive import HiveCatalog
from botocore.exceptions import ClientError, NoCredentialsError
from metadata import (
    DB_NAMESPACE,
    PATH_STORAGE,
    TABLE_NAME,
)
from pyiceberg.catalog import load_catalog
from pyiceberg.schema import NestedField, Schema
from pyiceberg.types import DoubleType, LongType, StringType
import boto3
import pyarrow as pa
import util

IP_REST = "181.4.11.11"
REST_URL = f"http://{IP_REST}:8181"
S3_CONFIG = {
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
BUCKET_NAME = "warehouse"
DIR_NAME = "pyiceberg"


def init_catalog():
    """Initialize catalog."""
    # # store metadata in SQLite
    # catalog = load_catalog(
    #     CATALOG_NAME,
    #     **{
    #         "uri": f"sqlite:///{WH_SQLITE}/pyiceberg_catalog_sqlite.db",
    #         "warehouse": f"file://{WH_SQLITE}",
    #     },
    # )

    catalog = load_catalog(
        CATALOG_NAME,
        **{
            "uri": REST_URL,
            "s3.endpoint": S3_CONFIG["endpoint"],
            "s3.access-key-id": S3_CONFIG["access-id"],
            "s3.secret-access-key": S3_CONFIG["secret-key"],
            "hive.hive2-compatible": True,
        },
    )

    return catalog


def delete_data_in_s3(s3_client, bucket_name: str, dir_name: str) -> None:
    """Clean up the bucket within the scope of S3.

    Args:
        s3_client: client to interact with S3
        bucket_name: bucket name where data is stored
        dir_name: directory where the data is stored
    """
    try:
        response = s3_client.list_buckets()
        print("Connected to MinIO successfully!\nBuckets are:")
        for bucket in response["Buckets"]:
            print(f"--- {bucket['Name']}")
    except NoCredentialsError:
        print("Error: No AWS credentials found.")
    except ClientError as exc:
        print(f"Error: {exc.response['Error']['Message']}")
    except Exception as exc:
        print(f"An unexpected error occurred: {exc}")

    # list all objects in the directory then delete
    response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=f"{dir_name}/")

    if "Contents" not in response:
        print(f"The '{dir_name}/' in bucket '{bucket_name}' is empty")

        return

    for obj in response["Contents"]:
        print(f"Deleting: {obj['Key']}")
        s3_client.delete_object(Bucket=bucket_name, Key=obj["Key"])

    print(f"Files in '{dir_name}' are deleted")

    return


def drop_metadata(catalog):
    """Drop metadata in the catalog.

    Args:
        catalog: catalog connected via pyiceberg
    """
    db_table = f"{DB_NAMESPACE}.{TABLE_NAME}"

    print(f"Dropping table '{db_table}'")
    catalog.purge_table(identifier=db_table)

    print(f"Dropping namespace '{db_table}'")
    catalog.drop_namespace(namespace=DB_NAMESPACE)
    return


def clean_up(catalog, s3_client, bucket_name: str, dir_name: str):
    """Clean up by deleting database.

    Args:
        catalog: the catalog
        s3_client: client to interact with S3
        bucket_name: bucket name where data is stored
        dir_name: directory where the data is stored
    """
    drop_metadata(catalog)

    delete_data_in_s3(s3_client=s3_client, bucket_name=bucket_name, dir_name=dir_name)

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
            # location=f"{WH_SQLITE}/{DIR_NAMESPACE}",
            location=f"s3a://{BUCKET_NAME}/{DIR_NAME}",
            # location=f"s3a://warehouse",
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

    s3_client = boto3.client(
        "s3",
        endpoint_url=S3_CONFIG["endpoint"],
        aws_access_key_id=S3_CONFIG["access-id"],
        aws_secret_access_key=S3_CONFIG["secret-key"],
        use_ssl=False,
    )

    main(catalog=catalog)

    clean_up(
        catalog=catalog,
        s3_client=s3_client,
        bucket_name=BUCKET_NAME,
        dir_name=DIR_NAME,
    )
