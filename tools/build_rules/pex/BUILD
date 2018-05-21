py_binary(
    name = 'pex_wrapper',
    visibility = [
        '//visibility:public',
    ],
    srcs = [
        'pex_wrapper.py',
    ],
)

pex_binary(
    name = 'foo',
    visibility = [
        '//visibility:public',
    ],
    srcs = [
        'foo.py',
    ],
    reqs = [
        'netaddr',
    ],
)
