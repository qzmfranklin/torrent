#!/usr/bin/env python3
'''Json formatter.

Specs of the custom json linter:
  - Only accept valid JSON string.
  - Append a new-line character to the end of the file.
  - Use 4-space indentation.
  - Sort keys.
'''

import argparse
import json


def execute(args):  # pylint: disable=missing-docstring
    for path in args.paths:
        with open(path, 'r') as f:
            data = json.load(f)
        with open(path, 'w') as f:
            json.dump(data, f, sort_keys=True, indent=args.indent)
            f.write('\n')


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        '--indent',
        metavar='N',
        type=int,
        default=4,
        choices=[2, 4],
        help='Number of spaces to use for indentation.'
    )
    parser.add_argument(
        'paths', nargs=argparse.REMAINDER, help='Paths to the files to format.'
    )
    args = parser.parse_args()
    execute(args)


if __name__ == '__main__':
    main()
