
This repo is for Kafka learning.

First of all, run `brew install kafka` install Kafka and Zookeeper via Homebrew locally.


## Concept

- Topic:
    - is a particular stream of data
    - similar to a table in a database (without all the constraints)
    - a topic is identified by its name
    - topics are split in partitions
- Parition:
    - each partition is ordered
    - each message within a partition gets an incremental id, called offset
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
    - it will be connected to the entire cluster once connecting to any broker (called a bootstrap broker)
    - every Kafka broker is also called a "bootstrap server"
    - each broker knows about all brokers, topics and partitions (metadata)
- Partition
    - only one broker can be a leader for a given partition at any time
    - only that leader can receive and serve data for a partition
    - other brokers will synchronize data from the leader
    - each partition has one leader and multiple ISR (In-Sync Replica)
    - leader and the ISR are taken care by Zookepper
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
    - consumers know hwich broker to read from
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

Kafka applies Zookeeper to manager its broker, so Kafka can't work work without Zookeeper:
- Zookeeper manages brokers (keeps a list of them)
- Zookeeper helps in performing leader election for partitions
- Zookeeper sends notifications to Kafka in case of changes, (e.g, new topic, broker dies, broker comes up, delete topics and so on)
- Zookeeper by design operates withn an odd number of servers (3, 5, 7, ...)
- Zookeeper has a leader (handle writes), the rest of the servers are followers (hadnle reads)

There are some guarantees Kafka admits:
- messages are appended to a topic-partition in the order they are sent
- consumers read messages in the order stored in a topic-partition
- within a relication factor of N, producers and consumers can tolerate up to N - 1 brokers being down
- a replication factor of 3 is a good idea, since it allows for one broker to be taken down for maintenance, while allowing for another broker to be taken down unexpectedly
- as long as the number of partitions remains constant for a topic(no new partitions), the same key will always go to the same partition


## Configuration

### Docker
To run Kafka via Docker, simply run `docker-compose -f zk-single-kafka-single.yml up` to start both Kafka and Zookeeper.

### Native
If it's to run Kafka locally, go to Kafka directory and config property in both Kafka and Zookeeper is recommended:
- "config/zookeeper.properties": `dataDir=/{dir}`
- "config/server.properties": `log.dirs=/{dir}`

After configuration, run:
- `zookeeper-server-start config/zookeeper.properties` to start up Zookeeper
- `zookeeper-server-start config/server.properties` to start Kafka


## Reference
- Udemy - Apache Kafka: https://www.udemy.com/course/apache-kafka/
- Kafka Stack Docker-Compose: https://github.com/simplesteph/kafka-stack-docker-compose
