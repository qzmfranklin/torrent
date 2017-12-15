#!/usr/bin/env python
"""One-line summary"""

import examples.python.pex.foo as foo

import flask
import yaml


def test_foo():
    """Main"""
    foo.main()


def test_yaml():
    yaml.dump({"herp": ["derp", "derp", "derp"]})


def test_flask():
    app = flask.Flask("foo")


def test_foo2():
    assert True
