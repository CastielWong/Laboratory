#!/usr/bin/env python
# -*- coding: utf-8 -*-


class User:
    def __init__(self, id_, username, password):
        # must set id for library werkzeug
        self.id = id_
        self.username = username
        self.password = password
