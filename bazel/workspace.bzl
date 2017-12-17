load('//tools/bazel_rules:github_archive.bzl', 'github_archive')


def repositories():
    # go_rules 0.8.0 breaks the build of the buildtools:
    #       https://github.com/bazelbuild/buildtools/issues/174
    github_archive(
        name = 'io_bazel_rules_go',
        github_user = 'bazelbuild',
        github_name = 'rules_go',
        commit = '0.7.1',
    )

    github_archive(
        name = 'io_bazel_rules_pex',
        github_user = 'qzmfranklin',
        github_name = 'bazel_rules_pex',
        commit = '2ee6864f73c32020c4f214a802ccb72d8f090b30',
    )

    github_archive(
        name = 'com_github_bazelbuild_buildtools',
        github_user = 'bazelbuild',
        github_name = 'buildtools',
        commit = '0.6.0',
    )
