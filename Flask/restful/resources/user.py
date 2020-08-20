#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3

from flask_restful import Resource, reqparse

from restful import config
from restful.models.user import UserModel


class UserRegister(Resource):

    parser = reqparse.RequestParser()
    parser.add_argument("username", type=str, required=True, help="User's name")
    parser.add_argument("password", type=str, required=True, help="User's password")

    def post(self):
        data = UserRegister.parser.parse_args()

        if UserModel.find_by_username(data["username"]):
            return {"message": "A user with the same username already exists."}, 400

        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "INSERT INTO Users VALUES (NULL, ?, ?)"
        cursor.execute(query, (data["username"], data["password"],))

        connection.commit()
        connection.close()

        return {"message": "User created successfully."}, 201
