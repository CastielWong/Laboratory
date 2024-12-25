
This is the demo project for Apache Iceberg, which is a high-performance format for
huge analytic tables.

- [Recipe](#recipe)
- [Concept](#concept)
  - [Metadata](#metadata)
  - [PyIceberg](#pyiceberg)
  - [PySpark](#pyspark)
- [Usage](#usage)
  - [MinIO](#minio)
- [Reference](#reference)


## Recipe
| Command    | Description                              |
|------------|------------------------------------------|
| make start | launch up container(s) for demo          |
| make run   | access into the primary container        |
| make end   | stop all relative container(s)           |
| make clean | clean up container(s), volume(s) created |


## Concept
Note that there are 2 aspects here: Metadata and Data.

The Metadata not only specify where the data is stored, but also point where itself
is stored and managed.

### Metadata
Catalog is at the top of metadata hierarchy.

The hierarchy for Iceberg data format is as:
Catalog -> Namespace -> Table

Mapping the concept from database to Iceberg:
| General  | Iceberg   |
|----------|-----------|
| database | catalog   |
| schema   | namespace |
| table    | table     |

### PyIceberg
There are several ways to configure PyIceberg for Catalog:
- local file system: SQLite
- cloud object storage: S3

### PySpark
To configure PySpark for Catalog:
- name: name of the Catalog
- type: what type of Catalog it is
- warehouse: where the Catalog is kept

For instance:
```py
{
  f"spark.sql.catalog.{catalog}": "org.apache.iceberg.spark.SparkCatalog",
  f"spark.sql.catalog.{catalog}.type": "hadoop",
  f"spark.sql.catalog.{catalog}.warehouse": "/home/iceberg/warehouse",
}
```


## Usage
1. Run `make run` to access to the primary container
2. Explore to see how it interacts with Iceberg:
   a. try the Python scripts under "/home/workspace/"
   b. check files generated inside
      - for local file system: "warehouse_fs/"
      - for cloud object storage: "warehouse_s3/"
   c. access to "localhost:9001" for MinIO web UI
3. Explore the "warehouse/" mapped to MinIO to gain better understanding

### MinIO
MinIO Client would be used for the interaction, common commands useful in debugging:
```sh
mc alias ls
```


## Reference
- Iceberg - quickstart: https://iceberg.apache.org/spark-quickstart/#docker-compose
- Iceberg - Spark Configuration: https://iceberg.apache.org/docs/1.6.0/spark-configuration/#catalogs
