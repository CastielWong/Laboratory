#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask
from flask_restful import Resource, Api, reqparse
from flask_jwt import JWT, jwt_required

from restful.security import authenticate, identity

app = Flask(__name__)
app.secret_key = "secret_for_demo"

api = Api(app)

jwt = JWT(app, authenticate, identity)

items = []


class Item(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument(
        "price", type=float, required=True, help="Price must be provided"
    )

    @jwt_required()
    def get(self, name):
        # `filter` would return the list, apply `next` for the first result
        item = next(filter(lambda x: x["name"] == name, items), None)

        return {"item": item}, 200 if item else 404

    @jwt_required()
    def post(self, name):
        item = next(filter(lambda x: x["name"] == name, items), None)
        if item:
            return {"message": f"An item named {name} already exists."}, 400

        data = Item.parser.parse_args()

        item = {"name": name, "price": data["price"]}
        items.append(item)
        return item, 201

    @jwt_required()
    def delete(self, name):
        global items
        items = list(filter(lambda x: x["name"] != name, items))
        return {"message": "Items deleted"}

    @jwt_required()
    def put(self, name):
        data = Item.parser.parse_args()

        item = next(filter(lambda x: x["name"] == name, items), None)
        if item is None:
            item = {"name": name, "price": data["price"]}
            items.append(item)
        else:
            item.update(data)
        return item


class ItemList(Resource):
    def get(self):
        return {"items": items}


api.add_resource(Item, "/item/<string:name>")
api.add_resource(ItemList, "/items")


if __name__ == "__main__":
    app.run(port=5000, debug=True)
