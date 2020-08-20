#!/usr/bin/env python
# -*- coding: utf-8 -*-

from restful.db import db


class UserModel(db.Model):
    __tablename__ = "Users"

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80))
    password = db.Column(db.String(80))

    def __init__(self, username, password):
        self.username = username
        self.password = password

    def json(self):
        return {"id": self.id, "username": self.username}

    @classmethod
    def find_by_username(cls, username):
        # SELECT * FROM Users WHERE username=? LIMIT 1
        return UserModel.query.filter_by(username=username).first()

    @classmethod
    def find_by_id(cls, id_):
        return UserModel.query.filter_by(id=id_).first()

    def save_to_db(self):
        db.session.add(self)
        db.session.commit()

    def delete_from_db(self):
        db.session.delete(self)
        db.session.commit()
