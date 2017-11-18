libtorrent_copts= [
    '-Wno-deprecated-declarations',
]

def single_file_example(name):
    native.cc_binary(
        name = name,
        srcs = [
            'github/examples/%s.cpp' % name,
        ],
        deps = [
            ':libtorrent',
        ],
        copts = libtorrent_copts,
    )
