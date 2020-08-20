#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask_restful import Api

from restful.app import app
from restful.db import db
from restful.resources.user import (
    UserRegister,
    User,
    UserLogin,
    UserLogout,
    TokenRefresh,
)
from restful.resources.item import Item, ItemList
from restful.resources.store import Store, StoreList

api = Api(app)

api.add_resource(UserRegister, "/register")
api.add_resource(User, "/user/<int:user_id>")
api.add_resource(UserLogin, "/login")
api.add_resource(UserLogout, "/logout")
api.add_resource(TokenRefresh, "/refresh")
api.add_resource(Store, "/store/<string:name>")
api.add_resource(StoreList, "/stores")
api.add_resource(Item, "/item/<string:name>")
api.add_resource(ItemList, "/items")

if __name__ == "__main__":
    # initialize SQLAlchemy with current application
    db.init_app(app)

    app.run(port=5000, debug=True)
