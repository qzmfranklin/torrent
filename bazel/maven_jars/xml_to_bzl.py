#!/usr/bin/env python3
'''Convert pom.xml snippets to yaml format.
'''

import sys
import xml.etree.ElementTree as ET
import yaml


def main():
    retval = {}
    tree = ET.parse('deps.xml')
    root = tree.getroot()
    # print(ET.tostring(root).decode())
    # print(root.tag)
    for dep in root.iter('dependency'):
        # print(ET.tostring(dep).decode())
        # print(ET.tostring(dep.find('groupId')).decode())
        # print(dep.find('groupId').text)
        group_id = dep.find('groupId').text
        artifact_id = dep.find('artifactId').text
        version = dep.find('version').text

        # Bazel does not accept names with dashes and dots.
        name = artifact_id.replace('-', '_').replace('.', '_')
        if name in retval:
            raise RuntimeError('Duplicate spec for artifact %s' % name)
        retval[name] = dict(
            artifact_id=artifact_id, group_id=group_id, version=version
        )

    # Output in yaml format, for human editing.
    yaml.dump(retval, sys.stdout, default_flow_style=False, indent=4)


if __name__ == '__main__':
    main()
