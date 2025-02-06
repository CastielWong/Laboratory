#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Access data in Iceberg format via pyiceberg."""

# from pyiceberg.catalog.hive import HiveCatalog
from botocore.exceptions import ClientError, NoCredentialsError
from colorama import Fore
import boto3
import colorama
import metadata
import util

DIR_NAMESPACE = "ns_sqlite"
DIR_NAME = "pyiceberg"


def delete_data_in_s3(s3_client, bucket_name: str, dir_name: str) -> None:  # noqa: C901
    """Clean up the bucket within the scope of S3.

    Args:
        s3_client: client to interact with S3
        bucket_name: bucket name where data is stored
        dir_name: directory where the data is stored
    """
    try:
        response = s3_client.list_buckets()
        print(Fore.BLUE + "Connected to MinIO successfully!\nBuckets are:")
        for bucket in response["Buckets"]:
            print(Fore.BLUE + f"\t- '{bucket['Name']}'")
    except NoCredentialsError:
        print(Fore.RED + "Error: No AWS credentials found.")
    except ClientError as exc:
        print(Fore.RED + f"Error: {exc.response['Error']['Message']}")
    except Exception as exc:
        print(Fore.RED + f"An unexpected error occurred: {exc}")

    # list all objects in the directory then delete
    response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=f"{dir_name}/")

    if "Contents" not in response:
        print(
            Fore.LIGHTRED_EX + f"The '{dir_name}/' in bucket '{bucket_name}' is empty"
        )

        return

    for obj in response["Contents"]:
        print(Fore.RED + f"Deleting: '{obj['Key']}'")
        s3_client.delete_object(Bucket=bucket_name, Key=obj["Key"])

    print(Fore.BLUE + f"Directory '{dir_name}' is pruned")

    return


def drop_metadata(catalog) -> None:
    """Drop metadata in the catalog.

    Args:
        catalog: catalog connected via pyiceberg
    """
    db_table = f"{metadata.DB_NAMESPACE}.{metadata.TABLE_NAME}"

    print(Fore.LIGHTRED_EX + f"Dropping table '{db_table}'")
    catalog.purge_table(identifier=db_table)

    print(Fore.LIGHTRED_EX + f"Dropping namespace '{db_table}'")
    catalog.drop_namespace(namespace=metadata.DB_NAMESPACE)
    return


def clean_up(catalog, s3_client, bucket_name: str, dir_name: str) -> None:
    """Clean up by deleting database.

    Args:
        catalog: the catalog
        s3_client: client to interact with S3
        bucket_name: bucket name where data is stored
        dir_name: directory where the data is stored
    """
    if not metadata.TO_CLEAN:
        print(Fore.YELLOW + "Note that clean up process is not activated.")
        return

    drop_metadata(catalog)

    delete_data_in_s3(s3_client=s3_client, bucket_name=bucket_name, dir_name=dir_name)

    return


def run_with_pyiceberg(catalog, location: str, namespace: str, table_name: str) -> None:
    """Run basic operations using pyiceberg.

    Args:
        catalog: the catalog
        location: where data is to store
        namespace: name of database
        table_name: name of table
    """
    db_table = f"{namespace}.{table_name}"

    # create namespace
    if namespace not in (x[0] for x in catalog.list_namespaces()):
        print(Fore.GREEN + f"Creating namespace '{namespace}'")
        catalog.create_namespace(namespace)

    # create table
    print(Fore.BLUE + f"Tables in '{namespace}' are: {catalog.list_tables(namespace)}")
    if table_name not in (x[1] for x in catalog.list_tables(namespace)):
        print(Fore.GREEN + f"Creating table '{table_name}'")
        catalog.create_table(
            db_table,
            schema=metadata.PYICEBERG_DATA_SCHEMA,
            location=location,
        )

    # append data
    table = catalog.load_table(db_table)
    table.append(metadata.PYICEBERG_SAMPLE_DATA)
    print(Fore.BLUE + f"Showing data in '{db_table}'")
    print(table.scan().to_pandas())

    return


@util.enclose_info
def main(catalog, storage: str) -> None:
    """Run the main.

    Args:
        catalog: the catalog
        storage: source of data is stored
    """
    print(Fore.BLUE + "List existing namespaces:")
    for ns in catalog.list_namespaces():
        print(ns)

    if storage == "fs":
        location = f"{metadata.FS_LOCAL_PATH}/{DIR_NAMESPACE}"
    elif storage == "s3":
        location = f"s3a://{metadata.S3_BUCKET}/{metadata.S3_DIR_NAME}"

    run_with_pyiceberg(
        catalog=catalog,
        location=location,
        namespace=metadata.DB_NAMESPACE,
        table_name=metadata.TABLE_NAME,
    )

    return


if __name__ == "__main__":
    storage = metadata.STORAGE

    colorama.init(autoreset=True)

    catalog = util.init_pyiceberg_catalog(storage=storage)

    main(catalog=catalog, storage=storage)

    if storage == "s3":
        s3_client = boto3.client(
            "s3",
            endpoint_url=metadata.S3_CONFIG["endpoint"],
            # aws_access_key_id=metadata.S3_CONFIG["read_access_id"],
            # aws_secret_access_key=metadata.S3_CONFIG["read_secret_key"],
            use_ssl=False,
        )

        clean_up(
            catalog=catalog,
            s3_client=s3_client,
            bucket_name=metadata.S3_BUCKET,
            dir_name=metadata.S3_DIR_NAME,
        )
