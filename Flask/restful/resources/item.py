#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask_restful import Resource, reqparse
from flask_jwt_extended import (
    jwt_required,
    get_jwt_claims,
    jwt_optional,
    get_jwt_identity,
    fresh_jwt_required,
)
from models.item import ItemModel


class Item(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument(
        "price", type=float, required=True, help="Price must be provided"
    )
    parser.add_argument(
        "store_id",
        type=int,
        required=True,
        help="Each item should has its corresponding store id",
    )

    @jwt_required
    def get(self, name):
        item = ItemModel.find_by_name(name)
        if item:
            return item.json()

        return {"message": "Item not found"}, 404

    @jwt_required
    def post(self, name):
        if ItemModel.find_by_name(name):
            return {"message": f"Item '{name}' already exists."}, 400

        data = Item.parser.parse_args()

        item = ItemModel(name, **data)

        try:
            item.save_to_db()
        except Exception as ex:
            print(ex)
            return {"message": "An exception occurred when inserting the item."}, 500

        return item.json(), 201

    @jwt_required
    def delete(self, name):
        claims = get_jwt_claims()

        if not claims["is_admin"]:
            return {"message": "Admin privilege required"}, 401

        item = ItemModel.find_by_name(name)

        if not item:
            return {"message": f"Item '{name}' doesn't exist."}, 400

        item.delete_from_db()

        return {"message": "Items deleted"}

    @fresh_jwt_required
    def put(self, name):
        data = Item.parser.parse_args()

        item = ItemModel.find_by_name(name)

        if item is None:
            item = ItemModel(name, data["price"], data["store_id"])
        else:
            item.price = data["price"]

        item.save_to_db()

        return item.json()


class ItemList(Resource):
    @jwt_optional
    def get(self):
        user_id = get_jwt_identity()
        # items = list(map(lambda x: x.json(), ItemModel.query.all()))
        items = [item.json() for item in ItemModel.find_all()]

        if user_id:
            return {"items": items}, 200

        return (
            {
                "items": [item["name"] for item in items],
                "message": "More data is available when log in",
            },
            200,
        )
