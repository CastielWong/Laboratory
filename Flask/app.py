#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return "This is the starting point"


app.run(port=5000)
