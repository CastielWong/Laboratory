#!/usr/bin/env python
# -*- coding: utf-8 -*-

from werkzeug.security import safe_str_cmp

from restful.models.user import UserModel


def authenticate(username, password):
    user = UserModel.find_by_username(username)
    if not user or not safe_str_cmp(user.password, password):
        return None

    return user


def identity(payload):
    user_id = payload["identity"]
    return UserModel.find_by_id(user_id)
