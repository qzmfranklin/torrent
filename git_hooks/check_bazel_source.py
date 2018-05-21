#!/usr/bin/env python3
'''Check that files are tracked by bazel as source files.
'''

# NOTE (zhongming): This module is probably going to look rather ad hoc to begin
# with because that is just want we would need.  Expect active refactoring in
# the future.

import argparse
import pathlib
import subprocess
import re
import sys

import common_util

THIS_DIR = pathlib.Path(__file__).resolve().parent
ROOT_DIR = THIS_DIR.parent


def get_untracked_files(paths):  # pylint: disable=too-many-locals
    '''Get the list of source files tracked by bazel.

    :param paths: Paths to the tracked source files.
    :type paths: List of pathlib.Path.

    :yield: Bazel targets.
    '''
    query_string = ' + '.join([str(x) for x in paths])
    # Disable color to simplify the parsing of the stderr output.
    cmd = ['bazel', 'query', '--keep_going', '--color=no', query_string]
    proc = subprocess.run(
        cmd,
        cwd=str(ROOT_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    retval = []
    prefix = 'ERROR: Skipping '
    pattern = prefix + r"'([a-zA-Z0-9_\./])+': no such target"
    for match in re.finditer(pattern, proc.stderr):
        i = match.start() + len(prefix)
        j = i + 1
        while proc.stderr[j] != "'":
            j += 1
        target = proc.stderr[i + 1:j]
        retval.append(target)
    return sorted(retval)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        '--ref',
        metavar='COMMIT',
        default='HEAD',
        help='''A git ref.  It could take any of the following formats:
            HEAD, HEAD~n, <branch>, <tag>, <commit-hash> The default value is
            HEAD, which causes only the staged changes to be considered.'''
    )
    # The unknown_args are used to ignore the files that pre-commit adds.
    args, unknown_args = parser.parse_known_args()  # pylint: disable=unused-variable

    changed_files = common_util.get_changed_files(args.ref)
    untracked_files = get_untracked_files(changed_files)
    if not untracked_files:
        sys.exit(0)
    print('WARNING: The following files are not tracked by bazel:')
    for path in untracked_files:
        print(' ' * 8 + str(path))
    print()
    print('See docs/files-not-tracked-in-bazel.rst for the next steps.')
    sys.exit(1)


if __name__ == '__main__':
    main()
