'''Common utility functions for modules under git_hooks.

Expect rapid refactoring here.

The goal is to have all of these under src/base/python.
'''

import pathlib
import subprocess

THIS_DIR = pathlib.Path(__file__).resolve().parent
ROOT_DIR = THIS_DIR.parent


def get_changed_files(ref):
    '''Yield changed file path, one at a time.

    :param ref: A git ref.  It could take any of the following formats:
            HEAD, HEAD~n, <branch>, <tag>, <commit-hash>
        The default value is HEAD, which causes only the staged changes to be
        considered.

    :type ref: str.

    :return: Path (pathlib.Path) of changed file.
    :rtype: List of pathlib.Path.
    '''
    cmd = ['git', 'diff', ref, '--name-only']
    proc = subprocess.run(
        cmd, cwd=str(ROOT_DIR), stdout=subprocess.PIPE, universal_newlines=True
    )
    retval = []
    for line in proc.stdout.rstrip().split('\n'):
        retval.append(pathlib.Path(line.rstrip()))
    return retval
