package(default_visibility=['//visibility:public'])

cc_binary(
    name = 'helloworld',
    srcs = [
        'helloworld.cc',
    ],
)

cc_binary(
    name = 'llvm_toy',
    srcs = [
        'llvm_toy.cc',
    ],
    deps = [
        '@clang//:lib',
    ],
    linkopts = [
        '-ldl',
        '-pthread',
    ],
    linkstatic = True,
)
