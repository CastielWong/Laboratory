#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Access data in Iceberg format via pyiceberg."""

# from pyiceberg.catalog.hive import HiveCatalog
from botocore.exceptions import ClientError, NoCredentialsError
from pyiceberg.catalog import load_catalog
import boto3
import metadata
import util

CATALOG_NAME = "default"
WH_SQLITE = metadata.FS_LOCAL_PATH
DIR_NAMESPACE = "ns_sqlite"
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
            "uri": metadata.REST_URL,
            "s3.endpoint": metadata.S3_CONFIG["endpoint"],
            # "s3.access-key-id": metadata.S3_CONFIG["admin_username"],
            # "s3.secret-access-key": metadata.S3_CONFIG["admin_password"],
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


def drop_metadata(catalog) -> None:
    """Drop metadata in the catalog.

    Args:
        catalog: catalog connected via pyiceberg
    """
    db_table = f"{metadata.DB_NAMESPACE}.{metadata.TABLE_NAME}"

    print(f"Dropping table '{db_table}'")
    catalog.purge_table(identifier=db_table)

    print(f"Dropping namespace '{db_table}'")
    catalog.drop_namespace(namespace=metadata.DB_NAMESPACE)
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
            schema=metadata.PYICEBERG_DATA_SCHEMA,
            # location=f"{WH_SQLITE}/{DIR_NAMESPACE}",
            location=f"s3a://{metadata.BUCKET_NAME}/{DIR_NAME}",
        )

    # append data
    table = catalog.load_table(db_table)
    table.append(metadata.PYICEBERG_SAMPLE_DATA)
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

    run_with_pyiceberg(
        catalog=catalog, namespace=metadata.DB_NAMESPACE, table_name=metadata.TABLE_NAME
    )

    return


if __name__ == "__main__":
    catalog = init_catalog()

    s3_client = boto3.client(
        "s3",
        endpoint_url=metadata.S3_CONFIG["endpoint"],
        # aws_access_key_id=metadata.S3_CONFIG["admin_username"],
        # aws_secret_access_key=metadata.S3_CONFIG["admin_password"],
        use_ssl=False,
    )

    main(catalog=catalog)

    clean_up(
        catalog=catalog,
        s3_client=s3_client,
        bucket_name=metadata.BUCKET_NAME,
        dir_name=DIR_NAME,
    )
