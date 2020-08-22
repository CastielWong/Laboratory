#!/usr/bin/env python
# -*- coding: utf-8 -*-

from datetime import timedelta

from flask import Flask, jsonify
from flask_jwt_extended import JWTManager

import config
from db import db

app = Flask(__name__)
app.secret_key = "secret_for_demo"

app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{config.DB_FOLDER}/{config.DB_NAME}"
# turn off Flask-SQLAlchemy tracker, but not the SQLAlchemy tracker
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False


@app.before_first_request
def create_tables():
    # note that SQLAlchemy would only create tables it can see here
    db.create_all()


# customize JSON Web Token configuration
app.config["JWT_EXPIRATION_DELTA"] = timedelta(seconds=1800)  # default is 300s
app.config["PROPAGATE_EXCEPTIONS"] = True
app.config["JWT_BLACKLIST_ENABLED"] = True
app.config["JWT_BLACKLIST_TOKEN_CHECKS"] = ["access", "refresh"]

# note that the configuration needs to be done before creating JWT
jwt = JWTManager(app)


@jwt.user_claims_loader
def add_claims_to_jwt(identity):
    # allow the first user only to be the admin
    if identity == 1:
        return {"is_admin": True}

    return {"is_admin": False}


@jwt.token_in_blacklist_loader
def check_if_token_in_blacklist(decrypted_token):
    return decrypted_token["jti"] in config.BLACKLIST


@jwt.expired_token_loader
def expired_token_callback():
    return (
        jsonify({"description": "The token has expired.", "error": "expired_token"}),
        401,
    )


@jwt.invalid_token_loader
def invalid_token_callback(error):
    # it's needed to keep the argument, since it's passed in by the caller internally
    return (
        jsonify(
            {"description": "The token is invalid.", "error": f"invalid_token: {error}"}
        ),
        401,
    )


@jwt.unauthorized_loader
def missing_token_callback(error):
    return (
        jsonify(
            {"description": "The token is missing.", "error": f"missing_token: {error}"}
        ),
        401,
    )


@jwt.needs_fresh_token_loader
def needs_fresh_token_callback():
    return (
        jsonify(
            {
                "description": "The token is needed to fresh.",
                "error": "needs_fresh_token",
            }
        ),
        401,
    )


@jwt.revoked_token_loader
def revoked_token_callback():
    return (
        jsonify(
            {"description": "The token has been revoked.", "error": "revoked_token"}
        ),
        401,
    )
