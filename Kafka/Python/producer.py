#!/usr/bin/env python
# -*- utf-8 -*-

# https://towardsdatascience.com/kafka-python-explained-in-10-lines-of-code-800e3e07dad1

from json import dumps
from time import sleep

from kafka import KafkaProducer


TOPIC = "numtest"
TOPIC = "testing"

producer = KafkaProducer(
    bootstrap_servers=["localhost:9092"],
    value_serializer=lambda x: dumps(x).encode("utf-8"),
)

for e in range(1000):
    data = {"number": e}
    print(data)
    producer.send(TOPIC, value=data)
    sleep(1)
