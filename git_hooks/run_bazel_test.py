#!/usr/bin/env python3
'''Run bazel tests before committing.


Compute the reverse dependencies of changed files and run all the tests that
could be broken by the changes.

All functions in this module always change to the root directory of this
repository when issuing commandline commands.
'''

# NOTE (zhongming): This module is probably going to look rather ad hoc to begin
# with because that is just want we would need.  Expect active refactoring in
# the future.

import argparse
import pathlib
import subprocess
import sys

import common_util

THIS_DIR = pathlib.Path(__file__).resolve().parent
ROOT_DIR = THIS_DIR.parent


def get_bazel_srcs(paths):
    '''Get the list of source files tracked by bazel.

    :param paths: Paths to the tracked source files.
    :type paths: List of pathlib.Path.

    :return: Bazel targets.
    :rtype: List of str.
    '''
    query_string = ' + '.join([str(x) for x in paths])
    # Do not remove --keep_going here.  If you want to warn about files
    # not tracked by bazel, write a separate git hook for it.
    cmd = ['bazel', 'query', '--keep_going', query_string]
    proc = subprocess.run(
        cmd,
        cwd=str(ROOT_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    retval = []
    for line in proc.stdout.rstrip().split('\n'):
        retval.append(line.rstrip())
    return retval


def get_affected_tests(changed_srcs, *, universe='//...'):
    '''Compute bazel targets affected by the changed files.

    :param changed_srcs: The list of changed source files.
    :type changed_srcs: List of str.

    :param universe: The full set of targets within which the reverse
        dependencies are computed.  This MUST be a valid bazel query expression.
        The default value, '//...', is equivalent to all targets under this
        repository.  See the link below for how-tos if you want to do other
        things with it:
            https://docs.bazel.build/versions/master/query-how-to.html
    :type universe: str.

    :return: The affected bazel tests.
    :rtype: List of str.
    '''
    if not changed_srcs:
        return []

    query_string = 'kind(".*_test rule", rdeps(tests(%s), %s))' % \
            (universe, ' + '.join([str(x) for x in changed_srcs]))
    # TODO (zhongming): Remove --keep_going.  This is kept so that some global
    # misconfigurations (such as with the docker rules) can be safely ignored.
    # But these problems must not persist much longer.
    cmd = ['bazel', 'query', '--keep_going', query_string]
    proc = subprocess.run(
        cmd, cwd=str(ROOT_DIR), stdout=subprocess.PIPE, universal_newlines=True
    )
    retval = []
    for line in proc.stdout.rstrip().split('\n'):
        retval.append(line.rstrip())
    return retval


def run_bazel_tests(tests):
    '''Run bazel tests.
    '''
    cmd = ['bazel', 'test'] + tests
    proc = subprocess.run(cmd, cwd=str(ROOT_DIR))
    return proc.returncode


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
    bazel_srcs = get_bazel_srcs(changed_files)
    affected_tests = get_affected_tests(bazel_srcs)
    rc = run_bazel_tests(affected_tests)
    sys.exit(rc)


if __name__ == '__main__':
    main()
