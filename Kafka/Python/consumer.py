#!/usr/bin/env python
# -*- utf-8 -*-

from json import loads

from kafka import KafkaConsumer

import producer

consumer = KafkaConsumer(
    producer.TOPIC,
    bootstrap_servers=["localhost:9092"],
    auto_offset_reset="earliest",
    enable_auto_commit=True,
    group_id="my-group",
    value_deserializer=lambda x: loads(x.decode("utf-8")),
)

for message in consumer:
    message = message.value
    print(f"-- {message} --")
