#!/usr/bin/env python3

import unittest

try:
    # Works when invoked from the examples/swig directory, e.g., via Makefile.
    import shape
except ImportError:
    # Works when invoked from `bazel test`.
    from examples.swig import shape


class TestExample(unittest.TestCase):

    def test_circle(self):
        width = 3
        a = shape.Square(width)
        self.assertEqual(12, a.perimeter())
        self.assertEqual(9, a.area())


if __name__ == '__main__':
    unittest.main()
