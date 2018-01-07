# TODO: The swig rules do not work yet.  Leave these here.

#load('@//tools/build_rules/swig:py_swig_library.bzl', 'py_swig_library')
#load('@//tools/build_rules/swig:swig_library.bzl', 'swig_library')
#package(default_visibility=['//visibility:public'])

#py_test(
    #name = 'py_shape_test',
    #srcs = [ 'python/shape_test.py' ],
    #main = 'python/shape_test.py',
    #deps = [ ':shape_py' ],
#)

#py_swig_library(
    #name = 'shape_py',
    #swig_library = ':shape_swig',
#)

#swig_library(
    #name = 'shape_swig',
    #interface_file = 'cc/interface.i',
    #module_name = 'shape',
    #cc_deps = [
        #':circle_cc_impl',
        #':square_cc_impl',
    #],
#)

#cc_library(
    #name = 'circle_cc_impl',
    #srcs = [ 'cc/Circle.cc' ],
    #hdrs = [ 'cc/Circle.h' ],
    #deps = [ ':shape_cc_impl' ],
#)

#cc_library(
    #name = 'square_cc_impl',
    #srcs = [ 'cc/Square.cc' ],
    #hdrs = [ 'cc/Square.h' ],
    #deps = [ ':shape_cc_impl' ],
#)

#cc_library(
    #name = 'shape_cc_impl',
    #srcs = [ 'cc/Shape.cc' ],
    #hdrs = [ 'cc/Shape.h' ],
#)
