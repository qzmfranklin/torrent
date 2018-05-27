#!/usr/bin/env python3

import unittest

# This importing scehma is ugly. But it would be really difficult to get rid of
# it considering we are using C/C++ bindings here.
from examples.swig import shape


class TestExample(unittest.TestCase):

    def test_circle(self):
        width = 3
        a = shape.Square(width)
        self.assertEqual(12, a.perimeter())
        self.assertEqual(9, a.area())


if __name__ == '__main__':
    unittest.main()
