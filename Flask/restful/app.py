#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask
from flask_restful import Api
from flask_jwt import JWT

from restful.security import authenticate, identity
from restful.user import UserRegister
from restful.item import Item, ItemList

app = Flask(__name__)
app.secret_key = "secret_for_demo"

api = Api(app)

jwt = JWT(app, authenticate, identity)


api.add_resource(Item, "/item/<string:name>")
api.add_resource(ItemList, "/items")
api.add_resource(UserRegister, "/register")


if __name__ == "__main__":
    app.run(port=5000, debug=True)
