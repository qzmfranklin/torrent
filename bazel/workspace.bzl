load('//bazel/maven_jars:load_maven_jars.bzl', 'load_maven_jars')
load('//tools/build_defs:github_archive.bzl', 'github_archive')

def repositories():
    load_maven_jars()

    # TODO (zhongming): After moving to our own git server, consolidate all of
    # these into a yaml configuration file and generate the load_git_archive.bzl
    # file.

    # docker rules
    github_archive(
        name = 'io_bazel_rules_docker',
        username = 'bazelbuild',
        reponame = 'rules_docker',
        commit = 'v0.4.0',
    )

    # go rules
    github_archive(
        name = 'io_bazel_rules_go',
        username = 'bazelbuild',
        reponame = 'rules_go',
        commit = '0.12.0',
    )
    github_archive(
        name = 'bazel_gazelle',
        username = 'bazelbuild',
        reponame = 'bazel-gazelle',
        commit = '0.11.0',
    )

    [ native.new_local_repository(
        name = name,
        path = path,
        build_file = 'bazel/system_libs/%s.BUILD' % name,
    ) for name, path in {
            'llvm': '/opt/clang/6.0.0',
            'cpython_hdrs': '/usr/include/python3.5m',
            'cpython_libs': '/usr/lib/x86_64-linux-gnu',
            # TODO (zhongming): Decide which path to use and automate via
            # ./config.
            #'cpython_libs': '/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu/',
        }.items()
    ]
