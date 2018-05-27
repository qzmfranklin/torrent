# TODO (zhongming): This file should become templatized via the ./config script.

cc_library(
    name = 'lib',
    visibility = [
        '//visibility:public',
    ],
    srcs = [
        'libpython3.5m.so',
        # TODO (zhongming): Static linking does not work for some reason.
        #'libpython3.5m.a',
    ],
)
