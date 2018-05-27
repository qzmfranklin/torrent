alias(
    name = 'llvm',
    actual = '@llvm//:lib',
)

cc_library(
    name = 'cpython',
    visibility = [
        '//visibility:public',
    ],
    deps = [
        '@cpython_hdrs//:lib',
        '@cpython_libs//:lib',
    ],
)
