#!/usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import timedelta

from flask import Flask
from flask_restful import Api
from flask_jwt import JWT

from restful.security import authenticate, identity
from restful.resources.user import UserRegister
from restful.resources.item import Item, ItemList

app = Flask(__name__)
app.secret_key = "secret_for_demo"

api = Api(app)

app.config["JWT_AUTH_URL_RULE"] = "/login"  # default is "/auth"
app.config["JWT_EXPIRATION_DELTA"] = timedelta(seconds=1800)  # default is 300s
# note that the configuration needs to be done before creating JWT
jwt = JWT(app, authenticate, identity)


api.add_resource(Item, "/item/<string:name>")
api.add_resource(ItemList, "/items")
api.add_resource(UserRegister, "/register")


if __name__ == "__main__":
    app.run(port=5000, debug=True)
