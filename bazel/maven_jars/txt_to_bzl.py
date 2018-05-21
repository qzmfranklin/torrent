#!/usr/bin/env python3
'''Convert plain text dependency file to yaml format.

TDOO: Removed this file once the Bazel structure is stablized.
'''

import sys
import yaml


def main():
    retval = {}
    with open('deps.txt', 'r') as f:
        for line in f:
            line = line.rstrip('\n\r')
            group_id, artifact_id, version = line.split(':')
            name = artifact_id.replace('-', '_').replace('.', '_')
            retval[name] = dict(
                artifact_id=artifact_id, group_id=group_id, version=version
            )

    yaml.dump(retval, sys.stdout, default_flow_style=False, indent=4)


if __name__ == '__main__':
    main()
