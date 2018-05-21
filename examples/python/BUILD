py_binary(
    name = 'foo_bin',
    srcs = [
        'foo_bin.py',
    ],
    deps = [
        ':foo_lib',
    ],
)

py_test(
    name = 'foo_test',
    srcs = [
        'foo_test.py',
    ],
    deps = [
        ':foo_lib',
    ],
    size = 'small',
)

py_library(
    name = 'foo_lib',
    srcs = [
        'foo_lib.py',
    ],
)

py_library(
    name = 'bar_lib',
    srcs = [
        'bar_lib.py',
    ],
)

pex_binary(
    name = 'bar_bin_pex',
    srcs = [
        'bar_bin.py',
    ],
    deps = [
        ':bar_lib',
    ],
    reqs = [
        'netaddr',
    ],
)
