#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3

from restful import config


class UserModel:
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
