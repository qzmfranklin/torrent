#!/usr/bin/env python3
'''Normalize the .gitmodules file.
'''

import configparser
import pathlib
import re

THIS_DIR = pathlib.Path(__file__).resolve().parent
ROOT_DIR = THIS_DIR.parent.parent
GITMODULES = ROOT_DIR / '.gitmodules'


class Submodule(object):
    '''A git submodule.
    '''

    # 'upstream' is not an officially supported attribute in git.
    GIT_ATTRS = ['path', 'url', 'branch', 'upstream']

    @classmethod
    def from_dict(cls, dd):
        '''Instantiate a Submodule from a dictionary.'''
        unknown_attrs = set(dd.keys()) - set(cls.GIT_ATTRS)
        if unknown_attrs:
            raise RuntimeError('Unknown submodule attribute(s)', unknown_attrs)
        return cls(**dd)

    def __init__(self, **kwargs):
        '''Private constructor.

        Please use from_*() instead of this method.
        '''
        self.__dict__.update(kwargs)

    def __str__(self):
        lines = []
        lines.append('[submodule "%s"]' % self.path)
        for attr in self.__class__.GIT_ATTRS:
            if hasattr(self, attr):
                # pylint: disable=no-member
                lines.append('    %s = %s' % (attr, getattr(self, attr)))
        return '\n'.join(lines)


def _get_submodules():
    '''Get a dictionary representing a submodule.

    Returns: A list of sorted dictionary, whose keys are fields in .gitmodules.
    '''
    retval = []
    submodule_regex = re.compile(r'^\[submodule ".*"\]$')
    with open(str(GITMODULES), 'r') as f:
        dd = {}
        for line in f:
            line = line.rstrip()

            # Example line:
            #       [submodule "third_party/boost"]
            if submodule_regex.match(line):
                if dd:
                    retval.append(Submodule.from_dict(dd))
                dd = {}
                continue

            # Example line:
            #       url = ../boost.git
            pos = line.find('=')
            assert pos != -1
            key = line[:pos].strip()
            val = line[pos + 1:].strip()
            dd[key] = val

    return sorted(retval, key=lambda x: x.path)


def main():
    for submodule in _get_submodules():
        upstream_file = ROOT_DIR / submodule.path / '.upstream'
        if upstream_file.is_file():
            config = configparser.ConfigParser()
            config.read(str(upstream_file))
            submodule.upstream = config['UPSTREAM'].get('url')
            submodule.branch = config['UPSTREAM'].get('branch')
        print(submodule)


if __name__ == '__main__':
    main()
