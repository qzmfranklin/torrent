'''
Base rule for using SWIG to call C/C++ from other programming langauges.
'''

# TODO: Improve documentation and completeness of this file.


def _swig_library_impl(ctx):
    compiler = ctx.attr.compiler

    # This relies on the 'swig' target to depend, via the 'data' keyword, on a
    # filegroup consisting all of the .swg and .i files.
    extra_inputs = []
    swig_include_dirs = depset()
    for file in compiler.data_runfiles.files:
        extra_inputs.append(file)
        dirname = file.dirname
        if not dirname in swig_include_dirs:
            swig_include_dirs += depset([dirname])

    # This is a hack to allow the swigwarn.swg file to be included at the
    # runtime.
    for filegroup in ctx.attr.swig_files:
        for file in filegroup.files:
            extra_inputs.append(file)
            dirname = file.dirname
            if not dirname in swig_include_dirs:
                swig_include_dirs += depset([dirname])
    swig_include_dirs = sorted(list(swig_include_dirs))

    # The list of C/C++ header files that may be included by the interface file.
    cc_hdrs = []
    for cc_lib in ctx.attr.cc_deps:
        for f in cc_lib.output_groups.compilation_prerequisites_INTERNAL_:
            if f.extension in ['h', 'hh', 'hpp']:
                cc_hdrs.append(f)

    return struct(swig_library=struct(
        # list of cc_library() target: The C/C++ libraries implmenting this
        # interface.
        cc_deps=ctx.attr.cc_deps,

        # File: The swig interface file to process.
        interface_file=list(ctx.attr.interface_file.files)[0],

        # File: The swig compiler.
        compiler=list(compiler.files)[0],

        # list of strings: The list of directories, relative to the execroot,
        # that the swig compiler needs to include, i.e., via '-I', at runtime.
        swig_include_dirs=swig_include_dirs,

        # List of Files: Files collected from the 'swig_files' attribute.
        extra_inputs=extra_inputs,

        # string: The module name.
        module_name=ctx.attr.module_name,

        # List of Files: The list of C/C++ header files that may be included by
        # the interface file.
        cc_hdrs=cc_hdrs,
    ))

_swig_library = rule(
    attrs = {
        'interface_file': attr.label(
            allow_files = True,
            executable = False,
            mandatory = True,
            single_file = True,
        ),
        'compiler': attr.label(
            mandatory = True,
            single_file = True,
        ),
        'swig_files': attr.label_list(
            allow_files = True,
            mandatory = False,
        ),
        'cc_deps': attr.label_list(
            mandatory = False,
            providers = ['cc'],
        ),
        'module_name': attr.string(
            mandatory = True,
        ),
    },
    implementation = _swig_library_impl,
)
''' Container for the C/C++ backend code and the SWIG interface file.

Arguments:
    interface_file: A SWIG interface file, with the .i extension.  See below for
        an example of the interface file:
            http://www.compiler.org/tutorial.html
    cc_deps: A list of cc_library() targets that this rule depdends on.  Those
        cc_library targets should implement the interface included in the
        interface_file.
    compiler: The SWIG compiler program.  Must be a XX_binary() label depending,
        via the 'data' keyword, on all the .swg and .i files needed by the swig
        compiler at runtime.  The default value is //third_party/cc/swig:swig.
        This executable will be invoked by depdending rules such as
        py_swig_library() to generate the boiler plate code that glues C/C++ to
        the corresponding programming language.
    swig_files: Files that the SWIG compiler will use at runtime.  Note that
        files included in the 'data' keyword of the compiler target, if any, are
        automatically collected at runtime.  You only need to use this argument
        to sepcify additional files.
    module_name: A string. The generated wrapper will use this as the module
        name.

TODO (zhongming): Add a 'compiler_path' keyword that is mutually exclusive with
the 'compiler' keyword to allow using a system installation of swig.
'''

def swig_library(interface_file, cc_deps=[], swig_files=[],
                 compiler='//third_party/cc/swig', **kwargs):
    swig_files = swig_files + ['//third_party/cc/swig:swigwarn_swg']
    _swig_library(interface_file=interface_file, cc_deps=cc_deps,
                  swig_files=swig_files, compiler=compiler, **kwargs)
