#!/usr/bin/env python3

'''
Recursively scan a directory and track git submodules to the upstreams.


This script recursively looks for a file named '.upstream', case sensitive, in the
directory.  The UPSTREAM file must conform to the configuration file format as
described below:
        https://docs.python.org/3/library/configparser.html#id14

An example '.upstream' file:
    ```
    [UPSTREAM]
    url = https://github.com/python/cpython
    branch = master
    ```

The url is the remote url.  The branch is the local branch to checkout.

A typical use case of this script is to initialize the submodules of a git
repository to checkout the correct local branch and track the correct upstream
repositories.
'''

import argparse
import configparser
import os
import pathlib
import subprocess
import validators


DEFAULT_UPSTREAM_FILENAME = '.upstream'
DEFAULT_UPSTREAM_NAME = 'upstream'


def _get_upstream_files(root_dir, *, upstream_file=DEFAULT_UPSTREAM_NAME):
    '''Get UPSTREAM configurations.

    :pathlib.Path root_dir: The root directory of the recursive search.
    :return: A generator object yielding a 2-tuple (path, config) upon each
        iteration, where path is a pathlib.Path object and config is a validated
        UPSTREAM configuration.
    '''
    for root, dirs, files in os.walk(root_dir):
        if upstream_file in files:
            path = pathlib.Path(root)
            upstream = path / upstream_file
            config = configparser.ConfigParser()
            config.read(str(upstream.absolute()))
            yield path, config


def execute(args):
    sorted_configs = sorted(list(_get_upstream_files(args.root_dir,
        upstream_file=args.upstream_file)), key=lambda x: x[0])
    for path, config in sorted_configs:
        url = config['UPSTREAM']['url']
        if not validators.url(url):
            raise ValueError('Invalid URL string', url)
        branch = config['UPSTREAM'].get('branch', 'master')

        print('cd', path.absolute(), '&& \\')
        cmd = ['git', 'remote', 'add', args.upstream_name, url]
        print('\t' + subprocess.list2cmdline(cmd) + ' && \\')
        cmd = ['git', 'checkout', branch]
        print('\t' + subprocess.list2cmdline(cmd))


def main():
    parser = argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--root-dir',
            default='.',
            help='The directory to scan and track upstream.')
    parser.add_argument('--upstream-name',
            default=DEFAULT_UPSTREAM_NAME,
            help='The name of the upstream branch as appeared in `git remote`.')
    parser.add_argument('--upstream-file',
            default=DEFAULT_UPSTREAM_FILENAME,
            help='The filename to look for in each directory.')
    args = parser.parse_args()
    execute(args)


if __name__ == '__main__':
    main()
