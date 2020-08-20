#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask_restful import Resource, reqparse
from flask_jwt import jwt_required

from restful.models.item import ItemModel


class Item(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument(
        "price", type=float, required=True, help="Price must be provided"
    )

    @jwt_required()
    def get(self, name):
        item = ItemModel.find_by_name(name)
        if item:
            return item.json()

        return {"message": "Item not found"}, 404

    @jwt_required()
    def post(self, name):
        if ItemModel.find_by_name(name):
            return {"message": f"An item with name '{name}' already exists."}, 400

        data = Item.parser.parse_args()

        item = ItemModel(name, data["price"])

        try:
            item.save_to_db()
        except Exception as ex:
            print(ex)
            return {"message": "An exception occurred when inserting the item."}, 500

        return item.json(), 201

    @jwt_required()
    def delete(self, name):
        item = ItemModel.find_by_name(name)

        if not item:
            return {"message": f"An item with name '{name}' doesn't exist."}, 400

        item.delete_from_db()

        return {"message": "Items deleted"}

    @jwt_required()
    def put(self, name):
        data = Item.parser.parse_args()

        item = ItemModel.find_by_name(name)

        if item is None:
            item = ItemModel(name, data["price"])
        else:
            item.price = data["price"]

        item.save_to_db()

        return item.json()


class ItemList(Resource):
    def get(self):
        # return {"items": list(map(lambda x: x.json(), ItemModel.query.all()))}
        return {"items": [item.json() for item in ItemModel.query.all()]}
