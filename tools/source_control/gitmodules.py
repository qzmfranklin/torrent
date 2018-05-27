#!/usr/bin/env python3
'''Normalize the .gitmodules file.

Read .upstream files for submodules, merge that information with .gitmodules.
Output to stdout the content of the normalized .gitmodules sorted in increasing
order of the path.  Also, the submodule's names are guaranteed to be the same as
the paths of the submodules.
'''

import configparser
import git_submodule


def main():
    for submodule in git_submodule.get_submodules():
        upstream_file = git_submodule.ROOT_DIR / submodule.path / '.upstream'
        if upstream_file.is_file():
            config = configparser.ConfigParser()
            config.read(str(upstream_file))
            submodule.upstream = config['UPSTREAM'].get('url')
            submodule.branch = config['UPSTREAM'].get('branch')
        print(submodule)


if __name__ == '__main__':
    main()
