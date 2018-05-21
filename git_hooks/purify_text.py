#!/usr/bin/env python3
r'''Purify text files.


1.  In each line, remove trailing whitespace characters.
    Whitespace characters are:
            \t \v \n \r space

2.  In each file, remove leading and trailing empty lines, i.e., the whole line
    only consists of whitespace characters.


3.  Add a UNIX new-line character \n to EOF if the EOF does not have one
    already.  The only exception to this rule is when the file is actually
    empty.


4.  Convert to UNIX line ending characters.
    This means to convert \r\n to \n.
'''

import argparse
import re

__EMPTYLINE_REGEX__ = re.compile(r'^\s*$')


def fix_lines(lines):
    '''Purify a list of lines.

    :param line: The list of lines to process.
    :type line: List of str.

    :return: The prified lines.
    :rtype: List of str.
    '''
    retval = []

    # Fix each line.
    for line in lines:
        line = fix_line(line)
        retval.append(line)

    # Remove leading and trailing empty lines.
    while retval and __EMPTYLINE_REGEX__.match(retval[0]):
        retval.pop(0)
    while retval and __EMPTYLINE_REGEX__.match(retval[-1]):
        retval.pop(-1)

    return retval


def fix_line(line):
    '''Purify one line.

    :param line: The line to process.
    :type line: str.

    :return: The prified line.
    :rtype: str.
    '''
    return line.rstrip() + '\n'


def execute(args):  # pylint: disable=missing-docstring
    for path in args.paths:
        with open(path, 'r') as f:
            old_lines = f.readlines()
        new_lines = fix_lines(old_lines)
        if old_lines != new_lines:
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
