#!usr/bin/env python
# -*- coding: utf-8 -*-

from threading import Thread
import random
import time

from flask import Flask, request
from flask_prometheus import monitor
import prometheus_client as prom

req_summary = prom.Summary("python_my_req_example", "Time spent processing a request")


@req_summary.time()
def process_request(t):
    time.sleep(t)


app = Flask("pyProm")


@app.route("/", methods=["GET", "POST"])
def home():
    if request.method == "GET":
        return "OK", 200, None

    return "Bad Request", 400, None


counter = prom.Counter("showing_counter", "This is the counter")
gauge = prom.Gauge("showing_gauge", "This is the gauge")
histogram = prom.Histogram("showing_histogram", "This is the histogram")
summary = prom.Summary("showing_summary", "This is the summary")


def generating():
    while True:
        counter.inc(random.random())
        gauge.set(random.random() * 15 - 5)
        histogram.observe(random.random() * 10)
        summary.observe(random.random() * 10)
        process_request(random.random() * 5)

        time.sleep(1)


Thread(target=generating).start()

monitor(app, port=8080)
app.run(host="0.0.0.0", port=80)
