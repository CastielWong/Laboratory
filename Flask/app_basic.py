#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, jsonify, request, render_template


app = Flask(__name__)

stores = [{"name": "The First Store", "items": [{"name": "Item 1", "price": 3.89}]}]


# GET /
@app.route("/")
def index():
    return render_template("index.html")


# POST /store data: {name:}
@app.route("/store", methods=["POST"])
def create_store():
    data = request.get_json()
    new_store = {"name": data["name"], "items": []}
    stores.append(new_store)
    return jsonify(new_store)


# GET /store/<string:name>
@app.route("/store/<string:name>")
def get_store(name):
    for store in stores:
        if store["name"] != name:
            continue
        return jsonify(store)

    return jsonify({"message": "store not found"})


# GET /store
@app.route("/store")
def get_stores():
    return jsonify({"stores": stores})


# POST /store/<string:name>/item {name:, price:}
@app.route("/store/<string:name>/item", methods=["POST"])
def create_item_in_store(name):
    data = request.get_json()
    for store in stores:
        if store["name"] != name:
            continue
        new_item = {"name": data["name"], "price": data["price"]}
        store["items"].append(new_item)
        return jsonify(new_item)

    return jsonify({"message": "store not found"})


# GET /store/<string:name>/item
@app.route("/store/<string:name>/item")
def get_item_in_store(name):
    for store in stores:
        if store["name"] != name:
            continue
        return jsonify({"items": store["items"]})

    return jsonify({"message": "store not found"})


app.run(port=5000)
