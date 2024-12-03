
This is the demo project for Apache Iceberg, which is a high-performance format for
huge analytic tables.

- [Recipe](#recipe)
- [Concept](#concept)
- [Usage](#usage)
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


## Usage
1. Run `make run` to access to the primary container
2. Explore to see how it interacts with Iceberg:
   a. try the Python scripts under "/home/workspace/"
   b. check files created inside "warehouse/"
   c. access to "localhost:9001" for MinIO web UI
3. Explore the "warehouse/" mapped to MinIO to gain better understanding


## Reference
- https://iceberg.apache.org/spark-quickstart/#docker-compose
