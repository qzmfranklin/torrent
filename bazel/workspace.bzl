def repositories():
    _third_party_binding()
    _bazel_rules()


def _bazel_rules():
    _pex_rules()


def _pex_rules():
    git_name = 'bazel_rules_pex'
    commit_md5 = '2ee6864f73c32020c4f214a802ccb72d8f090b30'
    native.http_archive(
        name = 'io_bazel_rules_pex',
        strip_prefix = '%s-%s' % (git_name, commit_md5),
        url = 'https://github.com/qzmfranklin/%s/archive/%s.tar.gz' % (git_name, commit_md5)
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
        name = 'libunwind',
        actual = '//third_party/libunwind:libunwind',
    )

    native.bind(
        name = 'openssl',
        actual = '//third_party/openssl:ssl',
    )

