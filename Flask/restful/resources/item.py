#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3
from flask_restful import Resource, reqparse
from flask_jwt import jwt_required

from restful import config
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
            item.insert()
        except Exception as ex:
            print(ex)
            return {"message": "An exception occurred when inserting the item."}, 500

        return item.json(), 201

    @jwt_required()
    def delete(self, name):
        if not ItemModel.find_by_name(name):
            return {"message": f"An item with name '{name}' doesn't exist."}, 400

        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "DELETE FROM Items WHERE name=?"
        cursor.execute(query, (name,))

        connection.commit()
        connection.close()

        return {"message": "Items deleted"}

    @jwt_required()
    def put(self, name):
        data = Item.parser.parse_args()

        item = ItemModel.find_by_name(name)

        updated_item = ItemModel(name, data["price"])

        if item is None:
            try:
                updated_item.insert()
            except Exception as ex:
                print(ex)
                return (
                    {"message": "An exception occurred when inserting the item."},
                    500,
                )
        else:
            try:
                updated_item.update()
            except Exception as ex:
                print(ex)
                return {"message": "An exception occurred when updating the item."}, 500

        return updated_item.json()


class ItemList(Resource):
    def get(self):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "SELECT * FROM Items"
        result = cursor.execute(query)

        items = []
        for row in result:
            items.append(ItemModel(*row).json())

        connection.close()

        return {"items": items}
