# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is modified from:
#   https://github.com/twitter/heron/blob/master/tools/rules/pex_rules.bzl

'''Build python pex binaries.

Dependency:
    pip3 install pex

KNOWN LIMITATIONS:
    Currently do not support prebuilt binaries (eggs or wheels).
'''


PY_EXTS = FileType(['.py'])
EGG_EXTS = FileType(['.egg', '.whl'])
REQ_EXTS = FileType(['.txt'])

# Repos file types according to:
#       https://www.python.org/dev/peps/pep-0527/
REPO_EXTS = FileType([
    '.egg', '.whl', '.tar.gz', '.zip', '.tar', '.tar.bz2', '.tar.xz', '.tar.Z',
    '.tgz', '.tbz'
])

def _collect_transitive_sources(ctx):
    source_files = depset(order='postorder')
    for dep in ctx.attr.deps:
        source_files += dep.py.transitive_sources
    source_files += PY_EXTS.filter(ctx.files.srcs)
    return source_files


def _collect_transitive_eggs(ctx):
    transitive_eggs = depset(order='postorder')
    for dep in ctx.attr.deps:
        if hasattr(dep.py, 'transitive_eggs'):
            transitive_eggs += dep.py.transitive_eggs
    transitive_eggs += EGG_EXTS.filter(ctx.files.eggs)
    return transitive_eggs


def _collect_transitive_reqs(ctx):
    transitive_reqs = depset(order='postorder')
    for dep in ctx.attr.deps:
        if hasattr(dep.py, 'transitive_reqs'):
            transitive_reqs += dep.py.transitive_reqs
    transitive_reqs += ctx.attr.reqs
    return transitive_reqs


def _collect_repos(ctx):
    repos = {}
    for dep in ctx.attr.deps:
        if hasattr(dep.py, 'repos'):
            repos += dep.py.repos
    for file in REPO_EXTS.filter(ctx.files.repos):
        repos.update({file.dirname: True})
    return repos.keys()


def _collect_transitive(ctx):
    return struct(
        # These rules don't use transitive_sources internally; it's just here for
        # parity with the native py_library rule type.
        transitive_sources=_collect_transitive_sources(ctx),
        #transitive_eggs=_collect_transitive_eggs(ctx),
        transitive_reqs=_collect_transitive_reqs(ctx),
        # uses_shared_libraries = ... # native py_library has this. What is it?
    )


def _gen_manifest(py, runfiles):
    '''Generate a manifest for pex_wrapper.

    Returns:
        struct(
            modules = [
                struct(src = 'path_on_disk', dest = 'path_in_pex'),
                ...
            ],
            requirements = ['pypi_package', ...],
        )
    '''

    pex_files = []

    for f in runfiles.files:
        dpath = f.short_path
        if dpath.startswith('../'):
            dpath = dpath[3:]
        pex_files.append(struct(
            src=f.path,
            dest=dpath,
        ), )

    return struct(
        modules=pex_files,
        requirements=list(py.transitive_reqs),
    )


def _pex_binary_impl(ctx):
    transitive_files = depset(ctx.files.srcs)

    if ctx.attr.entry_point and ctx.file.main:
        fail('Please specify either entry_point or main, not both.')
    if ctx.attr.entry_point:
        entry_point = ctx.attr.entry_point
        main_file = None
    elif ctx.file.main:
        main_file = ctx.file.main
    else:
        main_file = PY_EXTS.filter(ctx.files.srcs)[0]
    if main_file:
        # Translate main_file's short path into a python module name.
        entry_point = main_file.short_path.replace('/', '.')[:-3]
        transitive_files += [main_file]

    if not entry_point:
        fail('Must specify either entry_point or main, not neither.')

    deploy_pex = ctx.actions.declare_file(ctx.label.name + '.pex')


    for dep in ctx.attr.deps:
        transitive_files += dep.default_runfiles.files
    runfiles = ctx.runfiles(
        collect_default=True,
        transitive_files=transitive_files,
    )

    manifest_file = ctx.new_file(
        ctx.configuration.bin_dir, deploy_pex, '.manifest'
    )

    py = _collect_transitive(ctx)
    manifest = _gen_manifest(py, runfiles)

    ctx.file_action(
        output=manifest_file,
        content=manifest.to_json(),
    )

    # TODO (zhongming): Try using ctx.actions.args:
    #       https://docs.bazel.build/versions/master/skylark/lib/Args.html
    args = ['-o', deploy_pex.path]
    if not ctx.attr.use_wheels:
        args.append('--no-use-wheel')
    if not ctx.attr.zip_safe:
        args.append('--not-zip-safe')
    if ctx.attr.no_pypi:
        args.append('--no-pypi')
    if ctx.attr.disable_cache:
        args.append('--disable-cache')
    if ctx.files.req_file:
        args += ['--requirement', ctx.files.req_file.path]
    repos = _collect_repos(ctx)
    for repo in repos:
        args += ['--repo', repo]
    args += [
        '--cache-dir', '.pex/build',
        '--entry-point', entry_point,
        '--pex-root', '.pex',
        '--inherit-path', 'prefer',

        # Use this shebang to be safe across platforms.
        '--python-shebang', '/usr/bin/env python3',

        # The manifest file generated by _gen_manifest().  This argument does
        # not exit in the original pex binary.
        '--manifest', manifest_file.path,
    ]

    ctx.actions.run(
        arguments=args,
        env={'PATH': '/bin:/usr/bin:/usr/local/bin'},
        executable=ctx.executable._pex_wrapper,
        execution_requirements={'requires-network': '1'},
        inputs=[manifest_file] + list(runfiles.files),
        mnemonic='PythonPex',
        outputs=[deploy_pex],
    )

    return [DefaultInfo(executable=deploy_pex, runfiles=runfiles)]


def _get_runfile_path(ctx, f):
    '''Return the path to f, relative to runfiles.'''
    if ctx.workspace_name:
        return ctx.workspace_name + '/' + f.short_path
    else:
        return f.short_path


pex_binary = rule(
    _pex_binary_impl,
    executable=True,
    attrs={
        'data': attr.label_list(allow_files=True, cfg='data'),
        'deps': attr.label_list(allow_files=False, providers=['py']),
        'disable_cache': attr.bool(default=False),
        'entry_point': attr.string(),
        'shebang': attr.string(),
        'main': attr.label(allow_files=True, single_file=True),
        'no_pypi': attr.bool(default=False),
        'use_wheels': attr.bool(default=True),
        'repos': attr.label_list(allow_files=REPO_EXTS),
        'req_file': attr.label(allow_single_file=REQ_EXTS),
        'reqs': attr.string_list(),
        'srcs': attr.label_list(allow_files=PY_EXTS),
        'zip_safe': attr.bool(default=True),
        '_pex_wrapper': attr.label(
            default=Label('//tools/build_rules/pex:pex_wrapper'),
            executable=True,
            cfg='host',
        ),
    },  # yapf: disable
)
'''Build a deployable pex executable.

Args:
  deps: Python module dependencies.

    `pex_library` and `py_library` rules should work here.

  reqs: External requirements to retrieve from pypi, in `requirements.txt` format.

    This feature will reduce build determinism!  It tells pex to resolve all
    the transitive python dependencies and fetch them from pypi.

    It is recommended that you use `eggs` instead where possible.

  req_file: Add requirements from a given requirements file.

    This feature will reduce build determinism!  It tells pex to resolve all
    the transitive python dependencies and fetch them from pypi.

    It is recommended that you use `eggs` or specify `no_pypi` instead where possible.

  no_pypi: If True, don't use pypi to resolve dependencies for `reqs` and `req_files`; Default: False

  disable_cache: Disable caching in the pex tool entirely. Default: False

  repos: Additional repository labels (filegroups of wheel/egg files) to look for requirements.

  data: Files to include as resources in the final pex binary.

    Putting other rules here will cause the *outputs* of those rules to be
    embedded in this one. Files will be included as-is. Paths in the archive
    will be relative to the workspace root.

  main: File to use as the entry_point.

    If unspecified, the first file from the `srcs` attribute will be used.

  entry_point: Name of a python module to use as the entry_point.

    e.g. `your.project.main`

    If unspecified, the `main` attribute will be used.
    It is an error to specify both main and entry_point.

  interpreter: Path to the python interpreter the pex should to use in its shebang line.
'''

# TODO (zhongming): The following files are used to bootstrap the pex
# environment from the network.  I do not like how these files are pinned down
# without the ability to upgrade.  But I also do not like to rely on the host
# machine to have installed the `pex` package via pip3.
#
#def pex_repositories():
#    '''Rules to be invoked from WORKSPACE for remote dependencies.'''
#    native.http_file(
#        name='pytest_whl',
#        url='https://pypi.python.org/packages/8c/7d/f5d71f0e28af32388e07bd4ce0dbd2b3539693aadcae4403266173ec87fa/pytest-3.2.3-py2.py3-none-any.whl',
#        sha256='81a25f36a97da3313e1125fce9e7bbbba565bc7fec3c5beb14c262ddab238ac1'
#    )
#
#    native.http_file(
#        name='py_whl',
#        url='https://pypi.python.org/packages/53/67/9620edf7803ab867b175e4fd23c7b8bd8eba11cb761514dcd2e726ef07da/py-1.4.34-py2.py3-none-any.whl',
#        sha256='2ccb79b01769d99115aa600d7eed99f524bf752bba8f041dc1c184853514655a'
#    )
#
#    native.http_file(
#        name='wheel_src',
#        url='https://pypi.python.org/packages/c9/1d/bd19e691fd4cfe908c76c429fe6e4436c9e83583c4414b54f6c85471954a/wheel-0.29.0.tar.gz',
#        sha256='1ebb8ad7e26b448e9caa4773d2357849bf80ff9e313964bcaf79cbf0201a1648',
#    )
#
#    native.http_file(
#        name='setuptools_whl',
#        url='https://pypi.python.org/packages/e5/53/92a8ac9d252ec170d9197dcf988f07e02305a06078d7e83a41ba4e3ed65b/setuptools-33.1.1-py2.py3-none-any.whl',
#        sha256='4ed8f634b11fbba8c0ba9db01a8d24ad464f97a615889e9780fc74ddec956711',
#    )
#
#    native.http_file(
#        name='pex_src',
#        url='https://pypi.python.org/packages/58/ab/ac60cf7f2e855a6e621f2bbfe88c4e2479658650c2af5f1f26f9fc6deefb/pex-1.2.13.tar.gz',
#        sha256='53b592ec04dc2829d8ea3a13842bfb378e1531ae788b10d0d5a1ea6cac45388c',
#    )
#
#    native.http_file(
#        name='requests_src',
#        url='https://pypi.python.org/packages/b0/e1/eab4fc3752e3d240468a8c0b284607899d2fbfb236a56b7377a329aa8d09/requests-2.18.4.tar.gz',
#        sha256='9c443e7324ba5b85070c4a818ade28bfabedf16ea10206da1132edaa6dda237e',
#    )
#
#    native.http_file(
#        name='urllib3_whl',
#        url='https://pypi.python.org/packages/63/cb/6965947c13a94236f6d4b8223e21beb4d576dc72e8130bd7880f600839b8/urllib3-1.22-py2.py3-none-any.whl',
#        sha256='06330f386d6e4b195fbfc736b297f58c5a892e4440e54d294d7004e3a9bbea1b',
#    )
#
#    native.http_file(
#        name='idna_whl',
#        url='https://pypi.python.org/packages/27/cc/6dd9a3869f15c2edfab863b992838277279ce92663d334df9ecf5106f5c6/idna-2.6-py2.py3-none-any.whl',
#        sha256='8c7309c718f94b3a625cb648ace320157ad16ff131ae0af362c9f21b80ef6ec4',
#    )
#
#    native.http_file(
#        name='certifi_whl',
#        url='https://pypi.python.org/packages/40/66/06130724e8205fc8c105db7edb92871c7fff7d31324d7f4405c762624a43/certifi-2017.7.27.1-py2.py3-none-any.whl',
#        sha256='54a07c09c586b0e4c619f02a5e94e36619da8e2b053e20f594348c0611803704',
#    )
#
#    native.http_file(
#        name='chardet_whl',
#        url='https://pypi.python.org/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl',
#        sha256='fc323ffcaeaed0e0a02bf4d117757b98aed530d9ed4531e3e15460124c106691',
#    )
#
#    native.new_http_archive(
#        name='virtualenv',
#        url='https://pypi.python.org/packages/d4/0c/9840c08189e030873387a73b90ada981885010dd9aea134d6de30cd24cb8/virtualenv-15.1.0.tar.gz',
#        sha256='02f8102c2436bb03b3ee6dede1919d1dac8a427541652e5ec95171ec8adbc93a',
#        strip_prefix='virtualenv-15.1.0',
#        build_file_content='\n'.join([
#            "py_binary(",
#            "    name = 'virtualenv',",
#            "    srcs = ['virtualenv.py'],",
#            # exclude .pyc: Otherwise bazel detects a change after running virtualenv.py
#            "    data = glob(['**/*'], exclude=['*.pyc']),",
#            "    visibility = ['//visibility:public'],",
#            ")",
#        ])
#    )
