#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3
from flask_restful import Resource, reqparse
from flask_jwt import jwt_required

from restful import config


class Item(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument(
        "price", type=float, required=True, help="Price must be provided"
    )

    @classmethod
    def find_by_name(cls, name):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "SELECT * FROM Items WHERE name=?"
        result = cursor.execute(query, (name,))
        row = result.fetchone()
        connection.close()

        if row:
            return {"item": {"name": row[0], "price": row[1]}}

        return None

    @classmethod
    def insert(cls, item):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "INSERT INTO Items VALUES (?, ?)"
        cursor.execute(query, (item["name"], item["price"],))

        connection.commit()
        connection.close()

    @classmethod
    def update(cls, item):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "UPDATE Items SET price=? WHERE name=?"
        cursor.execute(query, (item["price"], item["name"],))

        connection.commit()
        connection.close()

    @jwt_required()
    def get(self, name):
        item = Item.find_by_name(name)
        if item:
            return item

        return {"message": "Item not found"}, 404

    @jwt_required()
    def post(self, name):
        if Item.find_by_name(name):
            return {"message": f"An item with name '{name}' already exists."}, 400

        data = Item.parser.parse_args()

        item = {"name": name, "price": data["price"]}

        try:
            Item.insert(item)
        except Exception as ex:
            print(ex)
            return {"message": "An exception occurred when inserting the item."}, 500

        return item, 201

    @jwt_required()
    def delete(self, name):
        if not Item.find_by_name(name):
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

        item = Item.find_by_name(name)

        updated_item = {"name": name, "price": data["price"]}

        if item is None:
            try:
                Item.insert(updated_item)
            except Exception as ex:
                print(ex)
                return (
                    {"message": "An exception occurred when inserting the item."},
                    500,
                )
        else:
            try:
                Item.update(updated_item)
            except Exception as ex:
                print(ex)
                return {"message": "An exception occurred when updating the item."}, 500

        return updated_item


class ItemList(Resource):
    def get(self):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "SELECT * FROM Items"
        result = cursor.execute(query)

        items = []
        for row in result:
            items.append({"name": row[0], "price": row[1]})

        connection.close()

        return {"items": items}
