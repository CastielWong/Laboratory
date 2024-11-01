#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Utility module."""


def enclose_info(func):
    """Place lines in between to enclose the function for readability.

    Args:
        func: function to enclosed
    """

    def wrapper(*args, **kwargs):
        print("=" * 80)
        res = func(*args, **kwargs)
        print("=" * 80)
        return res

    return wrapper
