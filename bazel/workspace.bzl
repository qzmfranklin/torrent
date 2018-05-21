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
