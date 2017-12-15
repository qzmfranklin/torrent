licenses(['notice'])

cc_library(
    name = 'main',
    visibility = [
        '//visibility:public',
    ],
    srcs = [
        'main.cc',
    ],
    deps = [
        '//third_party/glog',
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
