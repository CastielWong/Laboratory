#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3

from restful import config

connection = sqlite3.connect(config.DB_NAME)
cursor = connection.cursor()

query = """
    CREATE TABLE IF NOT EXISTS Users (
        id          INTEGER PRIMARY KEY,
        username    TEXT,
        password    TEXT
    )
"""
cursor.execute(query)

query = """
    CREATE TABLE IF NOT EXISTS Items (
        name    TEXT,
        price   REAL
    )
"""
cursor.execute(query)

connection.commit()
connection.close()
