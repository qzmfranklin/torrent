# pylint: disable=missing-docstring
import unittest

import remove_modeline


class TestRemoveModeline(unittest.TestCase):

    def test_py_fix_lines(self):
        data = [
            # 2-tuples of (expected processed lines, lines)

            # empty file
            ([], []),
            ([], ['\n']),

            # no-changers
            (['foo\n'], ['foo\n']),

            # remove pycharm encoding pragma
            ([], ['  # coding: utf-8 \n']),
            ([], ['# coding: utf8\n']),
            ([], ['#  \t coding: utf8\n']),
            (['foo\n'], [
                '#  \t coding: utf8\n',
                'foo\n',
            ]),

            # remove vim mode line
            ([], ['# vim: utf8 \n']),
            (['foo\n'], ['# vim: utf8 \n', 'foo\n']),

            # remove encoding pragma
            ([], ['# -*- coding: UTF-8 -*-\n']),
            ([], ['# -*- coding: \tutf8 -*-\n']),
            ([], ['# -*- coding: \vutf8 -*-\n']),
        ]
        for expected, lines in data:
            actual = remove_modeline.py_fix_lines(lines)
            self.assertEqual(expected, actual)


if __name__ == '__main__':
    unittest.main()
