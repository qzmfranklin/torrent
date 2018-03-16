'''
Rule for calling C/C++ from python.
'''

MNEMONIC = 'SwigPyCompile'

IMPORT_PREFIX = '__swig_py__'

# The .cc file can be named arbitrarily, as long as it is unique.
CC_PATH_FORMAT = IMPORT_PREFIX + '/%s_wrap.cc'

# The .py and .so files must be named like this.  Otherwise, the resulting code
# won't be usable.
PY_PATH_FORMAT = IMPORT_PREFIX + '/%s.py'
SO_PATH_FORMAT = IMPORT_PREFIX + '/_%s.so'

def _py_swig_codegen_impl(ctx):
    _swig_library = ctx.attr.swig_library.swig_library
    compiler = _swig_library.compiler
    interface_file = _swig_library.interface_file
    module_name = _swig_library.module_name

    # Input files.
    # Only .h, .hh, and .hpp files are included.
    input_files = [compiler, interface_file]
    input_files += _swig_library.cc_hdrs
    input_files += _swig_library.extra_inputs

    # Output files.
    cc_file = ctx.new_file(CC_PATH_FORMAT % module_name)
    py_file = ctx.new_file(PY_PATH_FORMAT % module_name)

    # Arguments.
    arguments = ['-I' + d for d in _swig_library.swig_include_dirs] + [
        # Enable C++ parsing.
        '-c++',
        # Generate python wrappers.
        '-python',
        # Python specific flags.  Visible via `swig -python -help`.
        '-keyword',
        '-modern',
        '-modernargs',
        '-noproxydel',
        # -o <file>: Set name of C/C++ output file to <file>.
        # We use this flag to re-direct the .cc file to the desired location.
        '-o', cc_file.path,
        # -outdir <dir>: Set language specific files output directory to <dir>.
        # When combined with -python, the generated python wrapper file is
        # re-directed to <dir> but the C/C++ output file is not affected by this
        # flag.
        '-outdir', py_file.dirname,
        # Set the module name.
        '-module', module_name,
        interface_file.path,
    ]


    # Compile the interface into source files.
    ctx.actions.run(
        arguments = arguments,
        env = dict(LD_LIBRARY_PATH='/opt/clang/6.0.0/lib'),
        executable = compiler.path,
        inputs = input_files,
        mnemonic = MNEMONIC,
        outputs = [cc_file, py_file],
        progress_message = '%s %s' % (MNEMONIC, interface_file.path),
    )

    return struct(files=[cc_file, py_file])


_py_swig_codegen = rule(
    attrs = {
        'swig_library': attr.label(
            allow_files = False,
            executable = False,
            mandatory = True,
            providers = [ 'swig_library' ],
        ),
        'cpython_lib': attr.label(
            allow_files = False,
            mandatory = True,
            providers = [ 'cc' ],
        ),
    },
    output_to_genfiles = True,
    implementation = _py_swig_codegen_impl,
)
''' Container for the C/C++ backend code and the SWIG interface file.

Arguments:
    swig_library: A swig_library() target.
    cpython_lib: A cc_library() target containing libpython.so, libpython.a, and
        Python.h.

Provides:
    cc_file: File, a .cc file that wraps the code to python.  The file name
        depends on the module_name of the swig_library.  See CC_PATH_FORMAT.
    py_file: File, a .py file for other python scripts to import.  The file name
        depends on the module_name of the swig_library.  See PY_PATH_FORMAT.
'''


def _py_swig_so_impl(ctx):
    _swig_library = ctx.attr.swig_library.swig_library
    _cc_lib = ctx.attr.cc_wrap_lib

    # Input file.
    orig_so = None
    for f in _cc_lib.data_runfiles.files:
        # Account for both Linux and macOS.
        if f.extension in ['so', 'dylib']:
            orig_so = f
    if not orig_so:
        fail("%s does not provide a dynamically linked library." % _cc_lib.label)

    # Output file.
    output_so = ctx.new_file(SO_PATH_FORMAT % _swig_library.module_name)

    # Action.
    ctx.actions.run(
        #arguments = arguments,
        #env = dict(LD_LIBRARY_PATH='/opt/clang/6.0.0/lib'),
        executable = 'cp',
        inputs = [orig_so],
        #mnemonic = MNEMONIC,
        outputs = [output_so],
        #progress_message = '%s %s' % (MNEMONIC, interface_file.path),
    )


_py_swig_so = rule(
    attrs = {
        'swig_library': attr.label(
            mandatory = True,
            providers = [ 'swig_library' ],
        ),
        'cc_wrap_lib': attr.label(
            mandatory = True,
            providers = [ 'cc' ],
        ),
    },
    output_to_genfiles = True,
    implementation = _py_swig_so_impl,
)


def py_swig_library(name, swig_library, cpython_lib='//third_party/cc/cpython'):
    # Generate two files: the wrapper .cc file and the wrapper .py file.
    py_swig_codegen = '_%s_py_swig_codegen' % name
    _py_swig_codegen(
        name = py_swig_codegen,
        visibility = ['//visibility:private'],
        swig_library = swig_library,
        cpython_lib = cpython_lib,
    )

    # Use the native cc_library rule to compile the wrapper .cc file and link
    # against the cpython_lib.
    cc_wrap_lib = '_%s_cc_wrap_lib' % name
    native.cc_library(
        name = cc_wrap_lib,
        visibility = ['//visibility:private'],
        srcs = native.glob([
            ':' + py_swig_codegen,
        ], exclude = [
            '**/*.py',
        ]),
        # TODO: Use the line below instead of the glob() above.
        #srcs = [ ':' + CC_PATH_FORMAT % module_name ],
        # TODO: Fully understand the two keywords below and see how they can be
        # used here.
        #alwayslink = 1,
        #linkstatic = 0,
        deps = [ cpython_lib ],
    )

    # Copy the .so file from the previous step to _<module_name>.so.
    py_swig_so = '_%s_py_swig_so' % name
    _py_swig_so(
        name = py_swig_so,
        visibility = ['//visibility:private'],
        swig_library = swig_library,
        cc_wrap_lib = cc_wrap_lib,
    )

    # Create a py_library() using _<module_name>.so and the wrapper .py file.
    native.py_library(
        name = name,
        visibility = ['//visibility:public'],
        srcs = native.glob([
            ':' + py_swig_codegen,
            ':' + py_swig_so,
        ], exclude = [
            '*.cc',
        ]),
        imports = [ IMPORT_PREFIX ],
        data = [ ':' + py_swig_so ],
    )
