alias(
    name = 'llvm',
    actual = '@llvm//:lib',
)

cc_library(
    name = 'cpython_dynamic',
    visibility = [
        '//visibility:public',
    ],
    deps = [
        '@cpython_hdrs//:lib',
        '@cpython_libs//:dynamic_lib',
    ],
)

cc_library(
    name = 'cpython_static',
    visibility = [
        '//visibility:public',
    ],
    deps = [
        '@cpython_hdrs//:lib',
        '@cpython_libs//:static_lib',
    ],
)
