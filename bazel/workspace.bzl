load('//tools/bazel_rules:github_archive.bzl', 'github_archive')


def repositories():
    github_archive(
        name = 'io_bazel_rules_pex',
        github_user = 'qzmfranklin',
        github_name = 'bazel_rules_pex',
        commit = '2ee6864f73c32020c4f214a802ccb72d8f090b30',
    )
