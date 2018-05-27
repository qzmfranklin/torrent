# TODO: The swig rules do not work yet.  Leave these here.

load('@//tools/build_rules/swig:py_swig_library.bzl', 'py_swig_library')

py_test(
    name = 'py_shape_test',
    srcs = [ 'python/shape_test.py' ],
    main = 'python/shape_test.py',
    deps = [ ':shape_py' ],
)

py_swig_library(
    name = 'shape_py',
    visibility = [ '//visibility:public' ],
    interface_file = 'cc/interface.i',
    module_name = 'shape',
    deps = [ ':shape_cc_impl' ],
)

cc_library(
    name = 'shape_cc_impl',
    srcs = [ 'cc/Shape.cc' ],
    hdrs = [ 'cc/Shape.h' ],
)
