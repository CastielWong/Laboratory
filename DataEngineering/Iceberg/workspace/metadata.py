#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Metadata for both demo."""

import configparser
import os

import pyarrow as pa
import pyiceberg.schema as pi_type
import pyspark.sql.types as ps_type

_FILE_CONFIG = "config.ini"
CONFIG = configparser.ConfigParser()
CONFIG.read(_FILE_CONFIG)

# CATALOG_NAME = "local"
CATALOG_NAME = "remote"

APPROACH = CONFIG.get("General", "approach")
STORAGE = CONFIG.get("General", "storage")
TO_CLEAN = CONFIG.getboolean("General", "clean")
_IP_REST = CONFIG.get("General", "ip_rest")
REST_URL = f"http://{_IP_REST}:8181"

# Database
DB_NAMESPACE = CONFIG.get("Database", "namespace")
TABLE_NAME = CONFIG.get("Database", "table_name")

# FS
FS_LOCAL_PATH = CONFIG.get("FS", "local_path")

# S3
S3_BUCKET = CONFIG.get("S3", "bucket")
S3_DIR_NAME = CONFIG.get("S3", "dir_name")
S3_CONFIG = {
    "endpoint": CONFIG.get("S3", "endpoint"),
    "admin_username": os.getenv("AWS_ACCESS_KEY_ID", "Not Supplied"),
    "admin_password": os.getenv("AWS_SECRET_ACCESS_KEY", "Not Supplied"),
    "read_access_id": os.getenv("S3_READ_ACCESS_ID", "Not Set"),
    "read_secret_key": os.getenv("S3_READ_SECRET_KEY", "Not Set"),
}

# ==============================PySpark==============================
_CONF_FILESYSTEM = {
    # for iceberg
    # "spark.sql.extensions": (
    #     "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions"
    # ),
    # "spark.sql.catalog.spark_catalog":(
    #     "org.apache.iceberg.spark.SparkSessionCatalog"
    # ),
    "spark.sql.defaultCatalog": CATALOG_NAME,
    f"spark.sql.catalog.{CATALOG_NAME}": "org.apache.iceberg.spark.SparkCatalog",
    f"spark.sql.catalog.{CATALOG_NAME}.type": "hadoop",
    f"spark.sql.catalog.{CATALOG_NAME}.warehouse": f"file://{FS_LOCAL_PATH}",
    # # configure for Spark authentication
    # "spark.authenticate": "true",
    # "spark.authenticate.secret": spark_secret_key,
    # "spark.authenticate.enableSaslEncryption": "true",
    # # set timezone
    # "spark.sql.session.timeZone": timezone,
}
_CONF_S3 = {
    # for iceberg
    "spark.sql.extensions": "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions",  # noqa: E501
    "spark.sql.defaultCatalog": CATALOG_NAME,
    f"spark.sql.catalog.{CATALOG_NAME}": "org.apache.iceberg.spark.SparkCatalog",
    f"spark.sql.catalog.{CATALOG_NAME}.type": "rest",
    # f"spark.sql.catalog.{CATALOG_NAME}.type": "hadoop",
    # f"spark.sql.catalog.{CATALOG_NAME}.type": "hive",
    f"spark.sql.catalog.{CATALOG_NAME}.warehouse": f"s3a://{S3_BUCKET}/{S3_DIR_NAME}/",
    # f"spark.sql.catalog.{CATALOG_NAME}.uri": "thrift://spark-master:9083",
    f"spark.sql.catalog.{CATALOG_NAME}.io-impl": "org.apache.iceberg.aws.s3.S3FileIO",
    # # for data writing
    f"spark.sql.catalog.{CATALOG_NAME}.uri": REST_URL,
    f"spark.sql.catalog.{CATALOG_NAME}.s3.endpoint": S3_CONFIG["endpoint"],
    f"spark.sql.catalog.{CATALOG_NAME}.s3.access-key-id": S3_CONFIG["read_access_id"],
    f"spark.sql.catalog.{CATALOG_NAME}.s3.secret-access-key": S3_CONFIG[
        "read_secret_key"
    ],
    # for reading data from S3
    "spark.hadoop.fs.s3a.endpoint": S3_CONFIG["endpoint"],
    "spark.hadoop.fs.s3a.access.key": S3_CONFIG["read_access_id"],
    "spark.hadoop.fs.s3a.secret.key": S3_CONFIG["read_secret_key"],
    "spark.hadoop.fs.s3a.path.style.access": "true",
    "spark.hadoop.fs.AbstractFileSystem.s3a.impl": "org.apache.hadoop.fs.s3a.S3A",
    "spark.hadoop.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
    "com.amazonaws.services.s3.enableV4": "true",
    "spark.hadoop.fs.s3a.aws.credentials.provider": "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider",  # noqa: E501
    # # for authenticating the Spark worker
    # "spark.authenticate": "true",
    # "spark.authenticate.secret": spark_secret_key,
    # "spark.authenticate.enableSaslEncryption": "true",
    # # allow DataNucleus to create table
    # "datanucleus.schema.autoCreateTables": "true",
    # # set timezone
    # "spark.sql.session.timeZone": "HongKong",
}

PYSPARK_CONFIG = {
    "fs": _CONF_FILESYSTEM,
    "s3": _CONF_S3,
}

PYICEBERG_CONFIG = {
    "fs": {  # store metadata in SQLite
        "uri": f"sqlite:///{FS_LOCAL_PATH}/pyiceberg_catalog_sqlite.db",
        "warehouse": f"file://{FS_LOCAL_PATH}",
    },
    "s3": {
        "uri": REST_URL,
        "s3.endpoint": S3_CONFIG["endpoint"],
        # "s3.access-key-id": S3_CONFIG["read_access_id"],
        # "s3.secret-access-key": S3_CONFIG["read_secret_key"],
        "hive.hive2-compatible": True,
        # "io-impl": "org.apache.iceberg.aws.s3.S3FileIO",
    },
}


PYSPARK_DATA_SCHEMA = ps_type.StructType(
    [
        ps_type.StructField("identifier", ps_type.LongType(), True),
        ps_type.StructField("fruit", ps_type.StringType(), True),
        ps_type.StructField("price", ps_type.DoubleType(), True),
    ]
)
PYSPARK_SAMPLE_DATA = [
    (1, "Apple", 1.89),
    (2, "Berry", 3.33),
    (3, "Cherry", 2.99),
    (4, "Date", 0.88),
    (5, "Fig", 5.55),
]

# ==============================PyIceberg==============================
PYICEBERG_DATA_SCHEMA = pi_type.Schema(
    pi_type.NestedField(
        field_id=1, name="identifier", field_type=pi_type.LongType(), required=False
    ),
    pi_type.NestedField(
        field_id=2, name="fruit", field_type=pi_type.StringType(), required=False
    ),
    pi_type.NestedField(
        field_id=3, name="price", field_type=pi_type.DoubleType(), required=False
    ),
)
PYICEBERG_SAMPLE_DATA = pa.Table.from_pylist(
    [
        {"identifier": 1, "fruit": "Apple", "price": 1.89},
        {"identifier": 2, "fruit": "Berry", "price": 3.33},
        {"identifier": 3, "fruit": "Cherry", "price": 2.99},
        {"identifier": 4, "fruit": "Date", "price": 0.88},
        {"identifier": 5, "fruit": "Fig", "price": 5.55},
    ]
)
