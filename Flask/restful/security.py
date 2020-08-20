#!/usr/bin/env python
# -*- coding: utf-8 -*-

from werkzeug.security import safe_str_cmp
from restful.user import User


def authenticate(username, password):
    user = User.find_by_username(username)
    if not user or not safe_str_cmp(user.password, password):
        return None

    return user


def identity(payload):
    user_id = payload["identity"]
    return User.find_by_id(user_id)
