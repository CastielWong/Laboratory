
- [Usage](#usage)
- [Concept](#concept)
  - [Hive-Server 2](#hive-server-2)
  - [Beeline](#beeline)
  - [Hive MetaStore Server](#hive-metastore-server)
- [Reference](#reference)

Apache Hive is a data warehouse infrastructure build over Hadoop platform for
performing data intensive task such as querying, analysis, processing and
visualization.

There are 2 modes for demonstration: "basic" and "integration".

Launch up either one to start the exploration.


## Usage
Access Hive via browser (http://localhost:10002) or inside the Hive server container:
- run `/opt/hive/bin/hive` then `!connect jdbc:hive2://localhost:10000`
- run `/opt/hive/bin/beeline -u 'jdbc:hive2://localhost:10000/'`
When there is no authentication enforced, "username" and "password" are not needed and
they can be skipped.

Query to execute in Beeline:
```sql
SHOW DATABASES;
SHOW TABLES;

CREATE DATABASE IF NOT EXISTS db_hive;
USE db_hive;
SHOW TABLES;

CREATE TABLE hive_demo (a STRING, b INT) PARTITIONED BY (c INT);

-- -- specify particular S3 bucket
-- CREATE TABLE hive_demo (a STRING, b INT)
-- STORED AS PARQUET
-- LOCATION 's3a://<bucket>/<dir>';

SELECT * FROM hive_demo;

ALTER TABLE hive_demo ADD PARTITION (c=1);

INSERT INTO hive_demo PARTITION (c=1) VALUES ('a', 1), ('a', 2), ('b', 3);

SELECT * FROM hive_demo;

SELECT COUNT(DISTINCT a) AS amount FROM hive_demo;

SELECT SUM(b) AS summation FROM hive_demo;

-- cleaning up
DROP TABLE IF EXISTS hive_demo;
SHOW TABLES;

USE default;
DROP DATABASE IF EXISTS db_hive CASCADE;
SHOW DATABASES;
```


## Concept

### Hive-Server 2
Hive-Server 2 (HS2) support multi-client concurrency and authentication, which
is designed to provide better support for open API clients like JDBC and ODBC.

### Beeline
Apache Beeline is a JDBC client based on the SQLLine CLI, which is a CLI
supported by HiveServer2 and is used to replace Hive CLI.

Beeline shell works in both embedded mode as well as remote mode.
In the embedded mode, it runs an embedded Hive whereas remote mode is for
connecting to a separate HiveServer2 process over Thrift.

### Hive MetaStore Server
The Hive MetaStore (HMS) is a central repository of metadata for Hive tables
and partitions in a relational database, and provides clients (including Hive,
Impala and Spark) access to this information using the MetaStore service API.

It has become a building block for data lakes that utilize the diverse world of
open-source software, such as Apache Spark and Presto.
In fact, a whole ecosystem of tools, open-source and otherwise, are built around
the Hive Me


## Reference
- CWiki: https://cwiki.apache.org/confluence/display/Hive
- Apache Beeline: https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients#HiveServer2Clients-Beeline%E2%80%93CommandLineShell
- Quickstart: https://hive.apache.org/development/quickstart/
- Docker Hub: https://hub.docker.com/r/apache/hive
- Docker Compose: https://github.com/apache/hive/blob/master/packaging/src/docker/docker-compose.yml
