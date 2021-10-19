
- [Concept](#concept)
- [Configuration](#configuration)
  - [Docker](#docker)
  - [Native](#native)
- [CLI](#cli)
  - [Topic](#topic)
  - [Producer](#producer)
  - [Consumer](#consumer)
- [Reference](#reference)

This repo is for Apache Kafka learning.

Kafka combines three key capabilities for event streaming end-to-end with a single battle-tested solution:
- To publish (write) and subscribe to (read) streams of events, including continuous import/export of your data from other systems
- To store streams of events durably and reliably for as long as wanted
- To process streams of events as they occur or retrospectively


First of all, run `brew install kafka` install Kafka and ZooKeeper via Homebrew locally.


## Concept

- Topic:
    - is a particular stream of data
    - similar to a table in a database (without all the constraints)
    - a topic is identified by its name
    - topics are split in partitions
- Partition:
    - each partition is ordered
    - each message within a partition gets an incremental id, called offset
    - only one broker can be a leader for a given partition at any time
    - only that leader can receive and serve data for a partition
    - other brokers will synchronize data from the leader
    - each partition has one leader and multiple ISR (In-Sync Replica)
    - leader and the ISR are taken care by ZooKeeper
    - each partition stored on broker's disk
    - partitions spread across brokers
- Offset:
    - offset only have a meaning for a specific partition
    - order is guaranteed only within a partition (not across partitions)
    - data is kept only for a limited time (default is one week)
    - once the data is written to a partition, it can't be changed
    - data is assigned randomly to a partition unless a key is provided
- Broker:
    - a Kafka cluster is composed of multiple brokers
    - each broker is identified with its ID
    - each broker contains certain topic partitions
    - each broker handles many partitions
    - it will be connected to the entire cluster once connecting to any broker (called a bootstrap broker)
    - every Kafka broker is also called a "bootstrap server"
    - each broker knows about all brokers, topics and partitions (metadata)
    - broker has configurable Retention Policy
- Producer
    - producers write data to topics
    - producers automatically know to which broker and partition to write to
    - in case of broker failures, producers will automatically recover
    - producers can choose to receive acknowledgment of data writes:
        - acks=0: won't wait for acknowledgment (possible data loss)
        - acks=1: will wait for leader acknowledgment (default, limited data loss)
        - acks=all: leader + replicas acknowledgment (no data loss)
    - producers can choose to send a key with the message
        - data is sent round robin when key is null
        - if a key is sent, all messages for that key will always go to the same partition
        - a key is basically sent if message ordering for a specific field is needed
- Consumer
    - consumer read data from a topic (identified by name)
    - consumers know which broker to read from
    - in case of broker failures, consumers know how to recover
    - data is read in order within each partitions
    - consumer offsets:
        - Kafka stores the offsets at which a consumer group has been reading
        - the offsets committed live in a Kafka topic named `__consumer_offsets`
        - when a consumer in a group has processed data received from Kafka, it should be committing the offsets
        - if a consumer dies, it will be able to read back from where it left off owing to the committed consumer offsets
        - consumers choose when to commit offsets, where there are 3 delivery semantics:
            - at most once
            - at least once
            - exactly once

Kafka applies ZooKeeper to manager its broker, so Kafka can't work work without ZooKeeper:
- ZooKeeper manages brokers (keeps a list of them)
- ZooKeeper helps in performing leader election for partitions
- ZooKeeper sends notifications to Kafka in case of changes, (e.g, new topic, broker dies, broker comes up, delete topics and so on)
- ZooKeeper by design operates within an odd number of servers (3, 5, 7, ...)
- ZooKeeper has a leader (handle writes), the rest of the servers are followers (handle reads)

ZooKeeper is going to be replaced by KIP (Kafka Improvement Proposal) 500, which is initiated to remove ZooKeeper from Kafka completely.

There are some guarantees Kafka admits:
- messages are appended to a topic-partition in the order they are sent
- consumers read messages in the order stored in a topic-partition
- within a replication factor of N, producers and consumers can tolerate up to N - 1 brokers being down
- a replication factor of 3 is a good idea, since it allows for one broker to be taken down for maintenance, while allowing for another broker to be taken down unexpectedly
- as long as the number of partitions remains constant for a topic(no new partitions), the same key will always go to the same partition


## Configuration

### Docker

To run Kafka via Docker, simply run `docker-compose -f zk-single-kafka-single.yml up` to start both Kafka and ZooKeeper.

### Native

If it's to run Kafka locally, go to Kafka directory and config property in both Kafka and ZooKeeper is recommended:
- "config/zookeeper.properties": `dataDir=/{dir}`
- "config/server.properties": `log.dirs=/{dir}`

After configuration, run:
- `zookeeper-server-start config/zookeeper.properties` to start up ZooKeeper
- `zookeeper-server-start config/server.properties` to start Kafka


## CLI

### Topic
- Topic is a Logical Representation
- Topics are stream of "related" Messages in Kafka
- Topics categorizes Messages into Groups
- Developers define Topics
- Producer <-> Topic: N to N relation
- Unlimited number of Topics
- A topic can be considered as a durable, persistent log, formally speaking a partition is a log

Since `kafka-topics --zookeeper 127.0.0.1:2181` is deprecated, it's suggested to use `kafka-topics --bootstrap-server 127.0.0.1:9092` instead.

Common commands:
```sh
# list topics
kafka-topics --bootstrap-server 127.0.0.1:9092 --list

# create a topic
kafka-topics --bootstrap-server 127.0.0.1:9092 --topic {topic} --create --partitions {m} --replication-factor {n}

# describe a topic
kafka-topics --bootstrap-server 127.0.0.1:9092 --topic {topic} --describe

# delete a topic
kafka-topics --bootstrap-server 127.0.0.1:9092 --topic {topic} --delete
```

### Producer

```sh
# start to produce message
kafka-console-producer --broker-list 127.0.0.1:9092 --topic {topic}

# produce message with key
kafka-console-producer --broker-list 127.0.0.1:9092 --topic {topic} --property parse.key=true --property key.separator={separator}
```

### Consumer

```sh
# start to consume message
kafka-console-consumer --bootstrap-server 127.0.0.1:9092 --topic {topic}

# consume message from the beginning with key
kafka-console-consumer --bootstrap-server 127.0.0.1:9092 --topic {topic} --from-beginning --property print.key=true --property key.separator={separator}

# multiple consumers consume message in the same group
kafka-console-consumer --bootstrap-server 127.0.0.1:9092 --topic {topic} --group {group}

# list existing consumer groups
kafka-consumer-groups --bootstrap-server 127.0.0.1:9092 --list
# describe a consumer group
kafka-consumer-groups --bootstrap-server 127.0.0.1:9092 --describe --group {group}
```


## Reference
- Introduction of Apache Kafka: https://kafka.apache.org/intro
- What is Apache Kafka: https://www.youtube.com/watch?v=06iRM1Ghr1k
- Apache Kafka: https://www.udemy.com/course/apache-kafka/
- Kafka Stack Docker-Compose: https://github.com/simplesteph/kafka-stack-docker-compose
- Kafka for Beginners: https://github.com/simplesteph/kafka-beginners-course
- Kafka Confluent Hub: https://www.confluent.io/hub/
- Apache Kafka Explained: https://www.youtube.com/watch?v=JalUUBKdcA0
