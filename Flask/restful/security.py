#!/usr/bin/env python
# -*- coding: utf-8 -*-

from werkzeug.security import safe_str_cmp
from restful.user import User

users = [User(1, "Alice", "alice_qwe")]

user_name_mapping = {u.username: u for u in users}
user_id_mapping = {u.id: u for u in users}


def authenticate(username, password):
    user = user_name_mapping.get(username, None)
    if not user or not safe_str_cmp(user.password, password):
        return None

    return user


def identity(payload):
    user_id = payload["identity"]
    return user_id_mapping.get(user_id, None)
