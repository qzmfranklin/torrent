#!/usr/bin/env python3
'''Remove editor specific mode lines for all files.


Source files should be agnostic about the editor used to edit them.

Supported editor-language combinations:

  - vim:
        Details are available at:
            http://vim.wikia.com/wiki/Modeline_magic
        In python, it usually takes the format of:
            (enclosed in ``` to avoid being removed by this script itself)
            ```# vim: ts=4 lb=80``

  - pycharm:
        PyCharm adds the following mode line to every .py file as the first
        line:
            (enclosed in ``` to avoid being removed by this script itself)
            ```# coding: utf-8```

  - python encoding pragma:
        Some python programmers have the habbit of adding the following encoding
        pragma:
            (enclosed in ``` to avoid being removed by this script itself):
            ```# -*- coding: UTF-8 -*-```

Also, to be consistent with our coding style of not having leading and trailing
empty lines, this script trims (after removing modelines) all leading and
trailing empty lines ensuring a newline character before EOF.
'''

import argparse
import re

import purify_text


def py_fix_lines(lines):
    '''Process python file content.

    :param lines: The original file content.
    :type lines: List of str.

    :return: The processed file content.
    :rtype: str.
    '''
    regex_strs = [
        # pycharm encoding line
        r'^\s*#\s*coding:.*$',
        # vim mode line
        r'^\s*#\s*vim:.*$',
        # encoding pragma
        r'^# \-\*\- coding: [a-zA-Z0-9\-_\t\v]{3,7} \-\*\-$',
    ]
    regexes = [re.compile(regex_str) for regex_str in regex_strs]

    new_lines = []
    for line in lines:
        should_add = True
        for regex in regexes:
            if regex.match(line):
                should_add = False
                break
        if should_add:
            new_lines.append(line)

    new_lines = purify_text.fix_lines(new_lines)

    return new_lines


def execute(args):  # pylint: disable=missing-docstring
    for path in args.paths:
        with open(path, 'r') as f:
            old_lines = f.readlines()
        new_lines = py_fix_lines(old_lines)
        if new_lines != old_lines:
            with open(path, 'w') as f:
                for line in new_lines:
                    f.write(line)
            print('Fixing', path)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        'paths', nargs=argparse.REMAINDER, help='Paths to the files to format.'
    )
    args = parser.parse_args()
    execute(args)


if __name__ == '__main__':
    main()
