#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

DB_FOLDER = "database"
DB_NAME = "data.sqlite"

BLACKLIST = set()


# create "database" folder is it didn't exit yet
root_abs = os.path.dirname((os.path.realpath(__file__)))
db_folder = os.path.join(root_abs, DB_FOLDER)
if not os.path.exists(db_folder):
    try:
        os.mkdir(db_folder)
    except FileExistsError as error:
        print(error)
