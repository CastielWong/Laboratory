#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Metadata for both demo."""

import pyarrow as pa
import pyiceberg.schema as pi_type
import pyspark.sql.types as ps_type

FS_LOCAL_PATH = "/home/iceberg/warehouse"
CATALOG_NAME = "local"
DB_NAMESPACE = "db_demo"
TABLE_NAME = "sample"

S3_BUCKET = "warehouse"
S3_CONFIG = {
    "endpoint": "http://minio:9000",
    "access-id": "admin",
    "secret-key": "password",
}

# ==============================PySpark==============================
_CONF_FILESYSTEM = {
    # for iceberg
    # "spark.sql.extensions": "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions",  # noqa: E501
    # "spark.sql.catalog.spark_catalog": "org.apache.iceberg.spark.SparkSessionCatalog",  # noqa: E501
    "spark.sql.defaultCatalog": CATALOG_NAME,
    f"spark.sql.catalog.{CATALOG_NAME}": "org.apache.iceberg.spark.SparkCatalog",
    f"spark.sql.catalog.{CATALOG_NAME}.type": "hadoop",
    f"spark.sql.catalog.{CATALOG_NAME}.warehouse": FS_LOCAL_PATH,
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
    f"spark.sql.catalog.{CATALOG_NAME}.type": "hive",
    f"spark.sql.catalog.{CATALOG_NAME}.warehouse": f"s3a://{S3_BUCKET}/",
    f"spark.sql.catalog.{CATALOG_NAME}.io-impl": "org.apache.iceberg.aws.s3.S3FileIO",
    # for reading data from S3
    "spark.hadoop.fs.AbstractFileSystem.s3a.impl": "org.apache.hadoop.fs.s3a.S3A",
    "com.amazonaws.services.s3.enableV4": "true",
    "spark.hadoop.fs.s3a.aws.credentials.provider": "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider",  # noqa: E501
    "spark.hadoop.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
    "spark.hadoop.fs.s3a.path.style.access": "true",
    "spark.hadoop.fs.s3a.endpoint": S3_CONFIG["endpoint"],
    "spark.hadoop.fs.s3a.access.key": S3_CONFIG["access-id"],
    "spark.hadoop.fs.s3a.secret.key": S3_CONFIG["secret-key"],
    # # for authenticating the Spark worker
    # "spark.authenticate": "true",
    # "spark.authenticate.secret": spark_secret_key,
    # "spark.authenticate.enableSaslEncryption": "true",
    # allow DataNucleus to create table
    "datanucleus.schema.autoCreateTables": "true",
    # # set timezone
    # "spark.sql.session.timeZone": timezone,
}


SPARK_CONFIG = {
    "fs": _CONF_FILESYSTEM,
    "s3": _CONF_S3,
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
