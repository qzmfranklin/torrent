#!/usr/bin/env python3
# pylint: disable=missing-docstring

import pathlib

import yaml

THIS_DIR = pathlib.Path(__file__).parent.resolve()  # pylint: disable=no-member
JARS_PATH = THIS_DIR / 'jars.yaml'


def main():
    with open(str(JARS_PATH), 'r') as f:  # pylint: disable=invalid-name
        data = yaml.load(f.read())
    with open(str(JARS_PATH), 'w') as f:  # pylint: disable=invalid-name
        f.write('---\n')  # Document-start for yaml files.
        f.write(yaml.dump(data, indent=4, default_flow_style=False))
    print('Sorted %s in-place.' % JARS_PATH)


if __name__ == '__main__':
    main()
