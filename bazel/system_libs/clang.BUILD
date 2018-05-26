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
    strip_include_prefix = 'include',
)
