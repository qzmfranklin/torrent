'''
Rule for calling C/C++ from python.
'''

MNEMONIC = 'PySwigCompile'


def _py_swig_codegen_impl(ctx):
    compiler = list(ctx.attr._swig_compiler.files)[0]
    interface_file = list(ctx.attr.interface_file.files)[0]
    module_name = ctx.attr.module_name

    input_files = [compiler, interface_file]

    # The list of C/C++ header files that may be included by the interface file.
    # Only .h, .hh, and .hpp files are included.
    for cc_lib in ctx.attr.deps:
        for f in cc_lib.output_groups.compilation_prerequisites_INTERNAL_:
            if f.extension in ['h', 'hh', 'hpp']:
                input_files.append(f)

    # Output files.
    cc_file, py_file = ctx.outputs.outs

    # Arguments.
    arguments = [
        # Enable C++ parsing.
        '-c++',
        # Generate python wrappers.
        '-python',
        # Python specific flags.  Visible via `swig -python -help`.
        #'-keyword',
        #'-modern',
        #'-modernargs',
        #'-noproxydel',
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

    ctx.actions.run(
        arguments=arguments,
        executable=compiler.path,
        inputs=input_files,
        mnemonic=MNEMONIC,
        outputs=ctx.outputs.outs,
        progress_message='%s %s' % (MNEMONIC, interface_file.path),
    )


_py_swig_codegen = rule(
    attrs={
        'deps': attr.label_list(
            providers=['cc'],
            default=[],
        ),
        'interface_file': attr.label(
            allow_single_file=True,
        ),
        'module_name': attr.string(),
        'outs': attr.output_list(),
        '_swig_compiler': attr.label(
            executable=True,
            cfg='host',
            default='//tools/build_rules/swig:swig_wrapper',
        ),
    },
    output_to_genfiles=True,
    implementation=_py_swig_codegen_impl,
)
''' Container for the C/C++ backend code and the SWIG interface file.

Arguments:
    deps: The list of cc_library targets that this swig pacakge depends on.
    interface_file: The swig interface file.
    module_name: The python module name to generate.
    outs: The list of output files that this rule provides.
    _swig_compiler: The swig compiler.
'''


def _py_swig_so_impl(ctx):
    if len(ctx.outputs.outs) > 1:
        fail('_py_swig_so may only have one output')
    new_file = ctx.outputs.outs[0]

    for f in ctx.attr.cc_lib.files:
        if f.path.endswith('.so'):
            orig_file = f
            break

    ctx.actions.run(
        arguments=[orig_file.path, new_file.path],
        executable='cp',
        inputs=[orig_file],
        outputs=ctx.outputs.outs,
    )


_py_swig_so = rule(
    attrs={
        'cc_lib': attr.label(providers=['cc']),
        'outs': attr.output_list(),
    },
    output_to_genfiles=True,
    implementation=_py_swig_so_impl
)
''' Move the shared library to the designated location.

Arguments:
    cc_lib: The shared library of this cc_library will be copied.
    outs: The list of outputs.  Only has one file.
'''


def py_swig_library(name, visibility, deps, interface_file, module_name,
                    copts=[], _cpython_lib='//:cpython'):
    '''
    Arguments:
        name: The name of this rule.
        visibility: The visibility of this rule.
        deps: The cc_library dependencies that implement the interface_file.
        interface_file: The swig interface file.
        module_name: The name of the python module.
        copts: Passed to cc_library().
        linkopts: Passed to cc_library().
        _cpython_lib: The cc_library containing Python.h and libpython3.X.so.


    Caveats:
        If the generated cxx wrapper source file cannot compile due to missing
        header files, you may patch the include paths via the copts argument.
        To ease the pain, if the interface_file is in a directory, then that
        directory is automatically added to the quote include path list, aka,
        via -I.
    '''
    # Generate two files: the wrapper .cc file and the wrapper .py file.  For
    # example:
    #   bazel-genfiles/examples/swig/__swig_py__/shape_wrap.cc
    #   bazel-genfiles/examples/swig/__swig_py__/shape.py
    py_swig_codegen = '_%s_swig_codegen' % name
    cc_file = '__swig_py__/%s_wrap.cc' % module_name
    py_file = '%s.py' % module_name
    codegen_outs = [cc_file, py_file]
    _py_swig_codegen(
        name = py_swig_codegen,
        visibility = ['//visibility:__pkg__'],
        deps = deps,
        interface_file = interface_file,
        module_name = module_name,
        outs = codegen_outs,
    )

    # Use the native cc_library rule to compile the wrapper .cc file and link
    # against the _cpython_lib.
    ccwrap_lib = '_%s_swig_ccwrap.so' % name
    toks = interface_file.split('/')
    if toks:
        interface_file_dirname = '/'.join([native.package_name()] + toks[:-1])
    else:
        interface_file_dirname = '.'
    native.cc_binary(
        name = ccwrap_lib,
        visibility = ['//visibility:__pkg__'],
        srcs = [ cc_file ],
        deps = deps + [ _cpython_lib ],
        copts = copts + [ '-I' + interface_file_dirname],
        linkshared = True,
    )

    # Move the generated .py file and the compiled library files into the same
    # directory.
    py_swig_so = '_%s_swig_so' % name
    so_file = '_%s.so' % module_name
    _py_swig_so(
        name = py_swig_so,
        cc_lib = ccwrap_lib,
        outs = [ so_file ],
    )

    # Define the actual py_library with the same name passed to this macro.
    native.py_library(
        name = name,
        visibility = visibility,
        srcs = [ py_file ],
        data = [ so_file ],
        # Skylark panics over the word 'import', so I cannot enable the line
        # below.
        #import = [ interface_file_dirname ],
    )
