#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask_restful import Resource, reqparse

from restful.models.user import UserModel


class UserRegister(Resource):

    parser = reqparse.RequestParser()
    parser.add_argument("username", type=str, required=True, help="User's name")
    parser.add_argument("password", type=str, required=True, help="User's password")

    def post(self):
        data = UserRegister.parser.parse_args()

        if UserModel.find_by_username(data["username"]):
            return {"message": "A user with the same username already exists."}, 400

        user = UserModel(**data)
        user.save_to_db()

        return {"message": "User created successfully."}, 201
