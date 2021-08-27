#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask_restful import Resource
from flask_jwt_extended import jwt_required, jwt_optional, get_jwt_identity
from models.store import StoreModel


class Store(Resource):
    @jwt_required
    def get(self, name):
        store = StoreModel.find_by_name(name)
        if store:
            return store.json()

        return {"message": "Store not found"}, 404

    @jwt_required
    def post(self, name):
        if StoreModel.find_by_name(name):
            return {"message": f"Store '{name}' already exists"}, 400

        store = StoreModel(name)
        try:
            store.save_to_db()
        except Exception as ex:
            print(ex)
            return {"message": "An exception occurred while creating the store"}, 500

        return store.json(), 201

    @jwt_required
    def delete(self, name):
        store = StoreModel.find_by_name(name)
        if store:
            store.delete_from_db()

        return {"message": "Store deleted"}


class StoreList(Resource):
    @jwt_optional
    def get(self):
        user_id = get_jwt_identity()
        stores = [store.json() for store in StoreModel.find_all()]

        if user_id:
            return {"stores": stores}, 200

        return (
            {
                "stores": [store["name"] for store in stores],
                "message": "More data is available when log in",
            },
            200,
        )
