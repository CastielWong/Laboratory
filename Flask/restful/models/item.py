#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3

from restful import config


class ItemModel:
    def __init__(self, name, price):
        self.name = name
        self.price = price

    def json(self):
        return {"name": self.name, "price": self.price}

    @classmethod
    def find_by_name(cls, name):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "SELECT * FROM Items WHERE name=?"
        result = cursor.execute(query, (name,))
        row = result.fetchone()
        connection.close()

        if row:
            return cls(*row)

        return None

    def insert(self):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "INSERT INTO Items VALUES (?, ?)"
        cursor.execute(query, (self.name, self.price,))

        connection.commit()
        connection.close()

    def update(self):
        connection = sqlite3.connect(config.DATABASE)
        cursor = connection.cursor()

        query = "UPDATE Items SET price=? WHERE name=?"
        cursor.execute(query, (self.price, self.name,))

        connection.commit()
        connection.close()
