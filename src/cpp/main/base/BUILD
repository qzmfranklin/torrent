licenses(['notice'])

cc_binary(
    name = 'gflags_example',
    srcs = [
        'gflags_example.cc',
    ],
    deps = [
        '//external:gflags',
    ],
)

cc_binary(
    name = 'glog_example',
    srcs = [
        'glog_example.cc',
    ],
    deps = [
        '//external:glog',
    ],
)

cc_library(
    name = 'main',
    visibility = [
        '//visibility:public',
    ],
    srcs = [
        'main.cc',
    ],
    deps = [
        '//external:glog',
    ],
)

cc_binary(
    name = 'demo_main',
    srcs = [
        'demo_main.cc',
    ],
    deps = [
        ':main',
    ],
)


cc_binary(
    name = 'helloworld',
    srcs = [
        'helloworld.cc',
    ],
)
