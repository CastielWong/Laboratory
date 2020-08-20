#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3

from flask_restful import Resource, reqparse

from restful import config


class User:
    def __init__(self, id_, username, password):
        # must set id for library werkzeug
        self.id = id_
        self.username = username
        self.password = password

    @classmethod
    def find_by_username(cls, username):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "SELECT * FROM Users WHERE username=?"
        result = cursor.execute(query, (username,))
        row = result.fetchone()

        user = None
        if row:
            user = cls(*row)

        connection.close()

        return user

    @classmethod
    def find_by_id(cls, id_):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "SELECT * FROM Users WHERE id=?"
        result = cursor.execute(query, (id_,))
        row = result.fetchone()

        user = None
        if row:
            user = cls(*row)

        connection.close()

        return user


class UserRegister(Resource):

    parser = reqparse.RequestParser()
    parser.add_argument("username", type=str, required=True, help="User's name")
    parser.add_argument("password", type=str, required=True, help="User's password")

    def post(self):
        data = UserRegister.parser.parse_args()

        if User.find_by_username(data["username"]):
            return {"message": "A user with the same username already exists."}, 400

        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "INSERT INTO Users VALUES (NULL, ?, ?)"
        cursor.execute(query, (data["username"], data["password"],))

        connection.commit()
        connection.close()

        return {"message": "User created successfully."}, 201
