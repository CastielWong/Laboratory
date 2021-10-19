
- [Quick Fact](#quick-fact)
- [Database Engine](#database-engine)
- [Table Engine](#table-engine)
  - [MergeTree](#mergetree)
- [Data Partitioning](#data-partitioning)
- [Use Case](#use-case)
  - [Trading](#trading)
    - [OHLC](#ohlc)
    - [Latest](#latest)
    - [Interval Aggregation](#interval-aggregation)
  - [TopK](#topk)
  - [Window Analysis](#window-analysis)
  - [Growth Ratio](#growth-ratio)
  - [Window Funnel](#window-funnel)
  - [Deduplication](#deduplication)
  - [Integrate BitMap](#integrate-bitmap)

ClickHouse: Click Stream, Data WareHouse

There are two engines in ClickHouse:
- Database Engine
- Table Engine

## Quick Fact
ClickHouse (Click Stream Data Warehouse, also known as CK) starts from OLAP scenario. It is customized with an efficient column-based storage engine, which achieves Data Stored in order, Primary Indexing, Sparse Indexing, Data Sharding, Data Partitioning, TTL, Master-Slave Replication and so on. These functionalities are founded the speedy analyzing performance for ClickHouse.

Feature:
- Data Partitioning
- Columnar storage
- Primary Index
- Secondary Index
- Data Compression
- Markup Flag

Disadvantage:
- no full transaction support
- sparse index, not good at granular or key-value query
- lack of high frequency (low latency) in data modification/deletion, only for batch modification or deletion
- not good at join


## Database Engine
There are 5 types of Database Engines:
- Ordinary: the default engine, which can use any types of Table Engine
- Dictionary: it will create table for every data dictionaries
- Memory: all data is only stored in memory, data will be lost when restarted, which can create memory engine only
- MySQL: it will pull data from remote MySQL database, and create MySQL (table) engine
- Lazy: it stores table into memory at the latest `expiration_time_in_seconds`, only applies to Log (table) engine


## Table Engine
The Table Engine is crucial in CLickHouse, it directly decides:
- how the data is stored and read
- whether it supports reading/writing concurrently
- whether it supports index
- types of query to support
- whether it supports replication

There are four categories of Table Engines, which consists of more than 30 kinds:
- Log: StripeLog, Log, TinyLog
- Integration: Kafka, MySQL, JDBC, ODBC, HDFS, MongoDB, S3, EmbeddedRocksDB, RabbitMQ, PostgreSQL, ExternalDistributed, MaterializedPostgreSQL
- Special
  - Distributed
  - External Data
  - Dictionary
  - Merge
  - File
  - Nul
  - Set
  - Join
  - URL
  - View
  - MaterializedView
  - Memory
  - Buffer
  - GenerateRandom
- MergeTree
  - MergeTree
  - Data Replication
  - Custom Partitioning Key
  - ReplacingMergeTree
  - SummingMergeTree
  - AggregatingMergeTree
  - CollapsingMergeTree
  - VersionedCollapsingMergeTree
  - GraphiteMergeTree

In general, __Log__, __Special__, and __Integration__ engines can be applied to limited scenarios, since their functionality is simple and used for special case normally. __MergeTree__ is divided into two types mainly, one is _Replicated_, while the other is _Distributed_, for which are combined in orthogonality to supply different functionalities.

### MergeTree
1. __MergeTree__ Table Engine is mainly used in analyzing large volumes of data, supporting data partition, storing data in order, indexing by primary key, indexing sparsely, supporting data TTL etc. __MergeTree__ supports all ClickHouse SQL, but some of them is inconsistent to MySQL, like PK in __MergeTree__ doesn't support deduplication.
2. To solve PK deduplication in __MergeTree__, ClickHouse provides __ReplacingMergeTree__ engine for deduplication. __ReplacingMergeTree__ ensures data is eventually deduplicated, but not guaranteeing PK wouldn't be repeated during query. Because the data of the same PK could be sharding to different nodes, while compaction can only be done in one node, and the time to optimize (deduplicate over nodes) is uncertain.
3. __CollapsingMergeTree__ engine is required to indicate a flag column "Sign" (value in 1 when indicated, -1 when deleted) in the table creation statement. At the backend, rows with the same PK yet opposite "Sign" will be folded/deleted during Compaction, which is to release the restriction of __ReplacingMergeTree__.
4. In order to solve the unfolding problem (when "sign" of -1 row appears before that of 1) introduced by __CollapsingMergeTree__  due to writing in random order, __VersionedCollapsingMergeTree__ engine appends a new column "Version" in its table creation statement. The "Version" column is used to record the relationship between status row and deleted row when writing in random order. Rows with the same PK, same "Version", opposite "Sign" will be deleted during Compaction.
5. Pre-Aggregation on PK columns is supported by __SummingMergeTree__. During Compaction, it would sum up rows whose PK are the same, and use a single row for the replacement, which reduces the storage cost a lot and improves performance when aggregating.
6. __AggregatingMergeTree__ is another Pre-Aggregation engine used to improve the performance of aggregated computing. Its difference from __SummingMergeTree__ is that __SummingMergeTree__ does only sum aggregation on non-PK columns, while __AggregatingMergeTree__ can used another aggregation functions.

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name (
  name1 [type] [DEFAULT|MATERIALIZED|ALIAS expr],
  name2 [type] [DEFAULT|MATERIALIZED|ALIAS expr],
  ...
) ENGINE = MergeTree()
    [PARTITION BY expr]
    [ORDER BY expr]
    [PRIMARY KEY expr]
    [SAMPLE BY expr]
    [SETTINGS name=value, ...]
```
- `PARTITION BY`: partition key, specifies how the table to be partitioned. The partitioned key can be a single column, or it can be a tuple of multiple columns, it supports expression in the meanwhile
- `ORDER BY`: order key, specifies how the data segment is ordered. By default, the ordered key is the same as PK
- `PRIMARY KEY`: primary key (PK), which will be the first layer index. By default, PK and order key are the same. Hence, `ORDER BY` is used to appoint the PK.
- `SETTINGS`:
  - `index_granularity` is used to specify the granularity of the index, whose default value is 8192. For __MergeTree__, only 1 index would be generated for every 8192 rows of data.
  - `index_granularity_bytes`, default is 10 M, which needs to enable via `enable_mixed_granularity_parts`.
- `SAMPLE BY`: the sampling expression, which is used to specify how to sample the data.



## Data Partitioning
The structure of a partition directory would follow the pattern like `/var/lib/clickhouse/data/{db}/{table}/{PartitionID_MinBlockNum_MaxBlockNUm_Level}`.

A partition may have multiple different directories, which stores data under the partition and other forms of meta data. Generally, multiple directories under the same partition would be merged at the backend. Description of each type of file:
- x.bin: data file, compressed in "LZ4" by default, corresponding to column "x"
- x.mrk2: mark file, whose name would be _x.mrk_ if the adjustable indexing gap is not enabled. It maps the sparse index between _primary.idx_ and _x.bin_, first finds the data offset via PK index, then retrieves the actual data from _x.bin_
- checksums.txt: checksum file for validation, stored in binary. It stores the size and the corresponding hash of any other files (like primary.idx, count.txt etc), so that to quickly validate the integrity and correctness.
- columns.txt: meta data of columns
- count.txt: record the total ros of data under current partition directory
- primary.idx: primary index

Sample Structure:
- col_1.bin
- col_1.mrk2
- col_2.bin
- col_2.mrk2
- date.bin
- date.mrk2
- checksums.txt
- primary.idx

Below is the steps how query is executed under the hood:
> Specify the partition
>
> -> specify the column (xxx.bin)
>
> -> get record from the mark file (xxx.mrk2) from primary index (primary.idx)
>
> -> scan the mark file to acquire two corresponding offsets
>   - the offset(position) of the compressed data segment in ".bin" file for current queried data
>   - the offset of the expected data after decompressed
>
> -> find the compressed data segment in ".bin" file based on the first offset
>
> -> read data to memory and decompress the data
>
> -> find the corresponding data based on the second offset in memory after decompression

Techniques involved:
- partition
- primary index
- secondary index
- data compression
- data mark


## Use Case
ClickHouse can be a good fit when:
- most of the query is reading and not limited to single-point access
- data is updated in batch (more than 1000 rows), but not single row, or none update at all
- data is just inserted into database, no need to modify
- reading data, the query asks for lots of rows, but just a small portion of columns
- table is wide, which means table has many columns
- the frequency of query is relative low, usually several hundred QPS or less per server
- regarding to simple query, it accepts 50 ms latency
- values for the column is small number or short string (e.g, each URL is limited to 60 bytes)
- a huge throughput is required when processing a single query, like billions of rows per second per sever
- no transaction support needed
- data consistency is in low demand
- each query only queries a big table, rest of tables is small
- the result returned is significantly smaller than data source, which means the data is filtered or aggregated, the size of returned result is no more than the memory of a server


### Trading
Sample data setup:
```sql
DROP TABLE IF EXISTS "uc_trading";

CREATE TABLE IF NOT EXISTS "uc_trading" (
  "epoch_time" Int64
  , "code" Int16
  , "price" Int16
) ENGINE = MergeTree()
PRIMARY KEY (code, epoch_time);

INSERT INTO "uc_trading" VALUES
(1577840400000000000, 1, 5), (1577840400000000000, 1, 4), (1577840400000000000, 2, 7),
(1577844000000000000, 1, 8), (1577847600000000000, 1, 2), (1577847600000000000, 1, 6),
(1578031200000000000, 2, 3), (1578031200000000000, 2, 8), (1578031200000000000, 2, 9),
(1578042000000000000, 1, 9), (1578042000000000000, 1, 5), (1578045600000000000, 1, 6),
(1578031200000000000, 2, 6), (1577959200000000000, 2, 4), (1577962800000000000, 2, 7);

SELECT  fromUnixTimestamp64Nano("epoch_time") AS "datetime", "code", "price"
FROM  "uc_trading"
ORDER BY "code", "datetime";
```


#### OHLC
Note that due to its implemented mechanism, ClickHouse can't guarantee the implicit insertion order when there are multiple records happened at the exact same timestamp. Additional column is needed if the insertion order matters.

```sql
SELECT  "code"
  , fromUnixTimestamp64Nano("epoch_time") AS "interval"
  , "prices"
  , "highest"
  , "lowest"
  , arrayElement(prices, 1) AS "open"
  , arrayElement(prices, -1) AS "close"
FROM (
  SELECT  "code"
    , "epoch_time"
    , max(price) AS "highest"
    , min(price) AS "lowest"
    , groupArray("price") AS "prices"
  FROM "uc_trading"
  GROUP BY "code", "epoch_time"
  ORDER BY "code"
  -- -- interval setting 1: can be used for nanosecond
  -- -- but need to set before converting to timestamp
  -- , "epoch_time" WITH FILL STEP toInt64(3600e9)
)
-- interval setting 2: more human-readable, but can't set millisecond or more granular
ORDER BY "interval" WITH FILL STEP dateDiff('second', now(), now() + INTERVAL 1 HOUR);
```

#### Latest
Though it's said to get the latest, solution below will return the first one when there are multiple records for the latest timestamp.

```sql
SELECT  "code"
  , arrayElement("prices", 1) AS "latest"
FROM (
  SELECT  "code"
    , groupArray("price") AS "prices"
  FROM (
    SELECT  "code", "price"
    FROM  "uc_trading"
    ORDER BY "code", "epoch_time" DESC
  )
  GROUP BY "code"
);
```

#### Interval Aggregation
Divide the time then round down, and multiple back to get each timestamp's corresponding interval.
```sql
-- more granular implementation
SELECT
    fromUnixTimestamp64Nano(
        intDiv("epoch_time", 7200e9) * toInt64(7200e9)
    ) AS "interval"
    , avg("price") AS "average"
FROM "uc_trading"
GROUP BY "interval"
ORDER BY "interval" ASC

-- restrict at second level though more human-readable
SELECT
  toStartOfInterval(
    fromUnixTimestamp64Nano("epoch_time"), INTERVAL 7200 second
  ) AS "interval"
  , avg("price") AS "average"
FROM "uc_trading"
GROUP BY "interval"
ORDER BY "interval" ASC
```



### TopK

```sql
DROP TABLE uc_topk;

CREATE TABLE IF NOT EXISTS uc_topk (
  a Int32
  , b Int32
  , c Int32
) ENGINE = Memory;

INSERT INTO uc_topk (a, b, c) VALUES
(1, 2, 5), (1, 2, 4), (1, 3, 8), (1, 3, 2), (1, 4, 6),
(2, 3, 3), (2, 3, 7), (2, 3, 8), (2, 4, 9), (2, 5, 6),
(3, 3, 4), (3, 3, 7), (3, 3, 5), (3, 4, 9), (3, 5, 6);

SELECT  *
FROM  uc_topk
ORDER BY a ASC;

SELECT  a, b, c
FROM  uc_topk
ORDER BY a ASC, c DESC;

SELECT  a, topK(3)(c)
FROM  uc_topk
GROUP BY a
ORDER BY a;

SELECT  a, topK(3)(c)
FROM  (
  SELECT a, c
  FROM  uc_topk
  ORDER BY a ASC, c DESC
  )
GROUP BY a
```


### Window Analysis
Could be good for bar/windowing:
- min
- max
- avg

Since HTTP Interface wouldn't work, such window functions only available in Command-line Client.
So make sure using the CLI via `clickhouse-client --host server -nm`, where `-nm` is for multiline queries, then config `SET allow_experimental_window_functions = 1;` before running window functions.

```sql
DROP TABLE uc_window;

CREATE TABLE IF NOT EXISTS uc_window (
  id String
  , score UInt8
) ENGINE = MergeTree()
ORDER BY id;

INSERT INTO uc_window(id, score) VALUES
('A', 90), ('A', 80), ('A', 88), ('A', 86), ('B', 91),
('B', 95), ('B', 90), ('C', 88), ('C', 89), ('C', 90);

SELECT * FROM uc_window;
SELECT * FROM uc_window ORDER BY id, score DESC;

SELECT id, score, sum(score) OVER(PARTITION BY id ORDER BY score) sum FROM uc_window;
SELECT id, score, max(score) OVER(PARTITION BY id ORDER BY score) max FROM uc_window;
SELECT id, score, min(score) OVER(PARTITION BY id ORDER BY score) min FROM uc_window;
SELECT id, score, avg(score) OVER(PARTITION BY id ORDER BY score) avg FROM uc_window;
SELECT id, score, count(score) OVER(PARTITION BY id ORDER BY score) count FROM uc_window;
```


### Growth Ratio
year-on-year growth = (CurrentMoth - ThisMonthLastYear) / CurrentMonth
month-to-month growth = (CurrentMonth - LastMonth) / LastMonth

```sql
WITH toDate('2020-01-01') AS start_date
SELECT
  toStartOfMonth(start_date + (number * 31)) AS month_start,
  (number + 20) * 100 AS amount,
  neighbor(amount, -12) AS prev_year_amount,
  neighbor(amount, -1) AS prev_month_amount,
  if(prev_year_amount = 0, -999, amount - prev_year_amount) AS year_inc,
  if(prev_year_amount = 0, -999, round((amount - prev_year_amount) / prev_year_amount, 4)) AS year_over_year,
  if(prev_year_amount = 0, -999, amount - prev_month_amount) AS month_inc,
  if(prev_year_amount = 0, -999, round((amount - prev_month_amount) / prev_month_amount, 4)) AS month_over_month
FROM numbers(24);
```

### Window Funnel
Tunnel model:
1. advertisement exposure           10 m
2. click                            200 k
3. view page                        190 k
4. add to cart                      20 k
5. make the order                   10 k
6. purchase                         8 k
7. purchase succeed                 7 k 5
8. order received (order finished)  6 k


### Deduplication
- functions for approximate deduplication: `uniq`, `uniqHLL12`, `uniqCombined`, `uniqCombined64`
- functions for extract deduplication: `uniqExact`, `groupBitmap`

### Integrate BitMap
The advantage of ClickHouse is that it applies to aggregated query analyses on big wide table for large volumes of data.
