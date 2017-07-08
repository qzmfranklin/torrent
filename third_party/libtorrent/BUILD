licenses(['notice'])
package(default_visibility=['//visibility:public'])
load(':libtorrent.bzl', 'single_file_example')


cc_library(
    name = 'libtorrent',
    srcs = glob([
        'github/ed25519/src/*.cpp',
        'github/src/*.cpp',
        'github/src/kademlia/*.cpp',
    ]),
    hdrs = glob([
        'github/ed25519/src/*.h',
        'github/include/libtorrent/**/*.hpp',
        'github/include/libtorrent/ConvertUTF.h'
    ]),
    includes = [
        'github/include',
        'github/ed25519/src',
    ],
    copts = [
        '-DBOOST_ASIO_ENABLE_CANCELIO=1',
        '-DBOOST_ASIO_HAS_STD_CHRONO=1',
        '-DBOOST_EXCEPTION_DISABLE=1',
        '-DHAVE_BOOST=/\\*\\*/',
        '-DHAVE_BOOST_SYSTEM=/\\*\\*/',
        '-DHAVE_CLOCK_GETTIME=1',
        '-DHAVE_CXX11=1',
        '-DHAVE_DLFCN_H=1',
        '-DHAVE_INTTYPES_H=1',
        '-DHAVE_MEMORY_H=1',
        '-DHAVE_PTHREAD=1',
        '-DHAVE_STDINT_H=1',
        '-DHAVE_STDLIB_H=1',
        '-DHAVE_STRINGS_H=1',
        '-DHAVE_STRING_H=1',
        '-DHAVE_SYS_STAT_H=1',
        '-DHAVE_SYS_TYPES_H=1',
        '-DHAVE_UNISTD_H=1',
        '-DLT_OBJDIR=\\".libs/\\"',
        '-DNDEBUG=1',
        '-DPACKAGE=\\"libtorrent-rasterbar\\"',
        '-DPACKAGE_BUGREPORT=\\"arvid@libtorrent.org\\"',
        '-DPACKAGE_NAME=\\"libtorrent-rasterbar\\"',
        '-DPACKAGE_STRING=\\"libtorrent-rasterbar\\ 1.2.0\\"',
        '-DPACKAGE_TARNAME=\\"libtorrent-rasterbar\\"',
        '-DPACKAGE_URL=\\"http://www.libtorrent.org\\"',
        '-DPACKAGE_VERSION=\\"1.2.0\\"',
        '-DSTDC_HEADERS=1',
        '-DTORRENT_BUILDING_SHARED=1',
        '-DTORRENT_USE_INVARIANT_CHECKS=0',
        '-DTORRENT_USE_LIBCRYPTO=1',
        '-DTORRENT_USE_OPENSSL=1',
        '-DVERSION=\\"1.2.0\\"',
        '-Wno-format-zero-length',
        '-ftemplate-depth=512',
        '-fvisibility-inlines-hidden',
        '-fvisibility=hidden',
        '-std=c++11',
    ] + [
        # Select the 1.0 version of the openssl API.
        '-DOPENSSL_API_COMPAT=0x10000000L',
    ],
    linkopts = [
        '-pthread',
        '-ldl',
    ],
    deps = [
        '//third_party/boost:asio',
        '//third_party/boost:crc',
        '//third_party/boost:date_time',
        '//third_party/boost:lexical_cast',
        '//third_party/boost:multiprecision',
        '//third_party/boost:pool',
        '//third_party/boost:system',
        '//third_party/boost:type_traits',
        '//third_party/boost:variant',
        '//third_party/openssl:ssl',
    ],
)

cc_binary(
    name = 'client',
    srcs = [
        'github/examples/client_test.cpp',
        'github/examples/print.cpp',
        'github/examples/print.hpp',
        'github/examples/session_view.cpp',
        'github/examples/session_view.hpp',
        'github/examples/torrent_view.cpp',
        'github/examples/torrent_view.hpp',
    ],
    deps = [
        ':libtorrent',
    ],
)

single_file_example('connection_tester')
single_file_example('dump_torrent')
single_file_example('make_torrent')
single_file_example('simple_client')
single_file_example('stats_counters')
single_file_example('upnp_test')
