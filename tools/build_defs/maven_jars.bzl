def maven_jars(coords):
    '''
    coords: A dictionary of the following format:
            {
                'name1': {
                    'artifact_id': 'protobuf-java',
                    'group_id': 'com.google.protobuf',
                    'version': '3.5.1',
                },
                ...
            }
        The 'name1' must not contain '-' or '.', which are forbidden by the
        Bazel maven_jar() rule.


    See Also:
        Bazel maven_jar() rule:
            https://docs.bazel.build/versions/master/be/workspace.html#maven_jar

    TODO:
        Add a keyword-only argument 'server' that allows all of maven jars to
        point to a maven_server() other than the default MavenCentral.
    '''
    for name, val in coords.items():
        group_id = val['group_id']
        artifact_id = val['artifact_id']
        version = val['version']
        artifact = '%s:%s:%s' % (group_id, artifact_id, version)
        native.maven_jar(name=name, artifact=artifact)
