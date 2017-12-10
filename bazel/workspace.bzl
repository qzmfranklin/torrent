load('//tools/bazel_rules:github_archive.bzl', 'github_archive')


def repositories():
    _third_party_binding()

    github_archive(
        name = 'io_bazel_rules_pex',
        github_user = 'qzmfranklin',
        github_name = 'bazel_rules_pex',
        commit = '2ee6864f73c32020c4f214a802ccb72d8f090b30',
    )


def _third_party_binding():
    # TODO: Remove bind().  See discussions here:
    #       https://github.com/bazelbuild/bazel/issues/1952
    native.bind(
        name = 'gflags',
        actual = '//third_party/gflags:gflags',
    )

    native.bind(
        name = 'glog',
        actual = '//third_party/glog:glog',
    )

    native.bind(
        name = 'gtest',
        actual = '//third_party/gtest:gtest',
    )

    native.bind(
        name = 'gtest_main',
        actual = '//third_party/gtest:gtest_main',
    )

    native.bind(
        name = 'jemalloc',
        actual = '//third_party/jemalloc:jemalloc',
    )

    native.bind(
        name = 'libunwind',
        actual = '//third_party/libunwind:libunwind',
    )

    native.bind(
        name = 'openssl',
        actual = '//third_party/openssl:ssl',
    )

