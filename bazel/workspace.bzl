def torrent_repositories():
    # Third party bindings.
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
