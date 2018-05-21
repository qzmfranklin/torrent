#!/usr/bin/env python3
'''Thin wrapper around checkstyle that exits 1 if there is ERROR or WARN.
'''

import sys
import pathlib
import re
import subprocess

THIS_DIR = pathlib.Path(__file__).resolve().parent
JAR_PATH = THIS_DIR.parent / 'third_party/java/checkstyle' \
        / 'checkstyle-8.10-all.jar'


def run_checkstyle(args):
    '''Run checkstyle.

    Anything prints to stdout and stderr are persisted to the calling shell of
    this script.

    :param args: Arguments directly passed to the actual checkstyle program.  If
        unsure, use '-h' to trigger the print of help messages.  More
        information of checkstyle on the command line can be found here:
                http://checkstyle.sourceforge.net/cmdline.html
    :type args: List of str.

    :return: If checkstyle is successful, return 0.  Otherwise, return 1.
    '''
    cmd = ['java', '-jar', str(JAR_PATH)] + args
    proc = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )

    regex = re.compile(r'^\[(WARN|ERROR)\] .*$')

    rc = 0

    if proc.stdout:
        for line in proc.stdout.split('\n'):
            if regex.match(line):
                rc = 1
                break
            print(line)
        if rc:
            print(proc.stdout)

    if proc.stderr:
        for line in proc.stderr.split('\n'):
            if regex.match(line):
                rc = 1
                break
        if rc:
            print(proc.stderr)

    return rc


def main():
    args = sys.argv[1:]
    sys.exit(run_checkstyle(args))


if __name__ == '__main__':
    main()
