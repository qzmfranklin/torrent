#!/usr/bin/env python3
'''
Recursively scan a directory and track git submodules to the upstreams.


This script recursively looks for a file named UPSTREAM, case sensitive, in the
directory.  The UPSTREAM file must conform to the configuration file format as
described below:
        https://docs.python.org/3/library/configparser.html#id14

At the root of each directory that has an UPSTREAM file, this script
    1.  Check that this is the root directory of a git repository.
    2.  Check that the branch named 'upstream' (configurable via the
        --upstream-name argument) does not exist.
    3.  Verify the content of the UPSTREAM file and extract the URL and branch.
    4.  If all the above checks succeeded, add a remote branch named 'upstream'
        and set the URL of the remote branch to URL extracted from the UPSTREAM
        file, less trailing whitespace characters.
'''

import argparse
import configparser
import os
import pathlib
import subprocess

import git_submodule

DEFAULT_UPSTREAM_FILENAME = '.upstream'
DEFAULT_UPSTREAM_NAME = 'upstream'
DEFAULT_UPSTREAM_SECTION_NAME = 'UPSTREAM'


def _get_upstream_files(root_dir, *, upstream_file='UPSTREAM'):
    '''Get UPSTREAM configurations.

    :pathlib.Path root_dir: The root directory of the recursive search.
    :return: A generator object yielding a 2-tuple (path, config) upon each
        iteration, where path is a pathlib.Path object and config is a validated
        UPSTREAM configuration.
    '''
    for root, _, _ in os.walk(str(root_dir)):
        path = pathlib.Path(root) / upstream_file
        if path.is_file():
            config = configparser.ConfigParser()
            config.read(str(path))
            yield path.parent, config[DEFAULT_UPSTREAM_SECTION_NAME]


def execute(args):  # pylint: disable=missing-docstring
    for submodule in git_submodule.get_submodules():
        print(submodule)
        cmds = []
        if hasattr(submodule, 'upstream'):
            cmds.append([
                'git',
                'remote',
                'add',
                '--track',
                submodule.branch,
                args.upstream_name,
                submodule.upstream,
            ])
            cmds.append([
                'git',
                'remote',
                'set-url',
                args.upstream_name,
                submodule.upstream,
            ])
        cmds.append([
            'git',
            'checkout',
            submodule.branch,
        ])
        path = pathlib.Path(submodule.path)
        if args.dry_run:
            print('cd', path.absolute())
            for cmd in cmds:
                print(subprocess.list2cmdline(cmd))
        else:
            for cmd in cmds:
                print(subprocess.list2cmdline(cmd))
                subprocess.run(cmd, cwd=str(path))


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        '--root-dir',
        type=pathlib.Path,
        default=pathlib.Path('.'),
        help='The directory to scan and track upstream.'
    )
    parser.add_argument(
        '--upstream-name',
        default=DEFAULT_UPSTREAM_NAME,
        help='The name of the upstream branch as appeared in `git remote`.'
    )
    parser.add_argument(
        '--upstream-file',
        default=DEFAULT_UPSTREAM_FILENAME,
        help='The filename to look for in each directory.'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='List the commands to run instead of running them.'
    )
    args = parser.parse_args()
    execute(args)


if __name__ == '__main__':
    main()
