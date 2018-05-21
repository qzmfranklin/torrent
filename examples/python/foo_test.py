# pylint: disable=missing-docstring

import unittest

import foo_lib


class TestFooLib(unittest.TestCase):

    # pylint: disable=no-self-use
    def test_bar(self):
        foo_lib.bar()


if __name__ == '__main__':
    unittest.main()
