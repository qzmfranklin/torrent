cc_library(
    name = 'lib',
    visibility = [
        '//visibility:public',
    ],
    srcs = glob([
        'lib/lib*.a',
        'lib/lib*.so',
    ]),
    hdrs = glob([
        'include/**/*',
    ]),
    linkopts = [
        # LLVM libraries are linked against stdc++ and a few other system
        # libraries.
        '-ldl',
        '-lm',
        '-lstdc++',
        '-pthread',
    ],
    strip_include_prefix = 'include',
)
