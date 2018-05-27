'''
Rule for calling C/C++ from python.
'''

MNEMONIC = 'PySwigCompile'


def _py_swig_codegen_impl(ctx):
    compiler = list(ctx.attr._swig_compiler.files)[0]
    interface_file = list(ctx.attr.interface_file.files)[0]
    module_name = ctx.attr.module_name

    input_files = [compiler, interface_file]


    # Add the .i and .swg files to the input files and the include directories
    # of swig.
    extra_args = []
    for filegroup in ctx.attr._swig_data:
        for file in filegroup.files:
            input_files.append(file)
            arg = None
            if file.path.endswith('.swg'):
                arg = '-I' + file.dirname
            if arg and arg not in extra_args:
                extra_args.append(arg)

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
        '-O',
        '-builtin',
        '-keyword',
        '-py3',
        '-relativeimport',
        '-threads',
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
    ] + sorted(extra_args) + [
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
            default='//third_party/cc/swig:swig',
        ),
        '_swig_data': attr.label_list(
            default=[
                '//third_party/cc/swig:swigwarn_swg',
                '//third_party/cc/swig:templates',
            ],
        )
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


def py_swig_library(name, visibility, deps, interface_file, module_name,
                    copts=[], _cpython_lib='//:cpython_dynamic'):
    '''
    Arguments:
        name: The name of this rule.
        visibility: The visibility of this rule.
        deps: The cc_library dependencies that implement the interface_file.
        interface_file: The swig interface file.
        module_name: The name of the python module.
        copts: Passed to cc_library().
        linkopts: Passed to cc_library().
        _cpython_lib: The cc_library containing Python.h and the source code (or
            prebuilt libraries).


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
    cc_file = '%s.py.swig.wrap.cc' % module_name
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
    # NOTE: This target must be named like this, i.e., '*.so', so that bazel
    # knows that this is building a dynamically linked library.  Otherwise,
    # bazel will complain that there is no main() function.
    # TODO (zhongming): Enable static linking?  So far cannot get it to work
    # yet.
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
        copts = copts + [
            '-I' + interface_file_dirname,
            # The list of copts here should mute whatever warnings rising from
            # compiling the generated C++ file.
            '-Wno-unused-variable',
        ],
        linkshared = True,
    )

    # Move the generated .py file and the compiled library files into the same
    # directory.
    so_file = '_%s.so' % module_name
    native.genrule(
        name = '_%s_swig_so' % name,
        srcs = [ ccwrap_lib ],
        outs = [ so_file ],
        cmd = 'cp $< $@',
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
