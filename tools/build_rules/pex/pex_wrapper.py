#!/usr/bin/env python3
# Copyright 2018 Zhongming Qu.
#
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
''' Pex builder wrapper '''

import json
import os
import pathlib

try:
    import pex
    import pex.bin.pex as pexbin
except ImportError:
    raise RuntimeError(
        'The host system must have installed python pex: pip3 install pex'
    )


def dereference_symlinks(src):
    '''
    Resolve all symbolic references that `src` points to.  Note that this
    is different than `os.path.realpath` as path components leading up to
    the final location may still be symbolic links.
    '''
    return str(pathlib.Path(src).resolve())


def update_parser(parser):
    ''' Update the argument parser.
    '''

    # This is using the deprecated optparser:
    #       https://docs.python.org/2/library/optparse.html
    # To Twitter developers: Can you please update this?
    parser.add_option(
        '--manifest', type='string', help='''The input manifest file.'''
    )


def _load_manifest(path):
    '''Load the file specified by path into a dictionary.

    The file must be in json format and conforms to the format documented like
    the following:
        dict(
            modules = [
                struct(src = 'path_on_disk', dest = 'path_in_pex'),
                ...
            ],
            requirements = ['pypi_package', ...],
            prebuilt_libs = ['path_on_disk', ...],
        )

    When in doubt, please consult the pex_rules.bzl file's _gen_manifest()
    function for more information.
    '''
    with open(path, 'r') as f:
        retval = json.load(f)
    for key in ['modules', 'requirements']:
        assert key in retval
    return retval


def main():  # pylint: disable=too-many-locals,too-many-statements
    parser, resolver_options_builder = pexbin.configure_clp()
    update_parser(parser)
    args, unused_args = parser.parse_args()
    if unused_args:
        raise RuntimeError('Unrecognized arguments %s' % unused_args)
    manifest = _load_manifest(args.manifest)

    if args.pex_root:
        pex.variables.ENV.set('PEX_ROOT', args.pex_root)
    else:
        args.pex_root = pex.variables.ENV.PEX_ROOT

    if args.cache_dir:
        args.cache_dir = pexbin.make_relative_to_root(args.cache_dir)
    args.interpreter_cache_dir = pexbin.make_relative_to_root(
        args.interpreter_cache_dir
    )

    reqs = manifest.get('requirements', [])

    with pex.variables.ENV.patch(PEX_VERBOSE=str(args.verbosity)):
        with pex.tracer.TRACER.timed('Building pex'):
            pex_builder = pexbin.build_pex(reqs, args, resolver_options_builder)

        # Add source files from the manifest
        for modmap in manifest.get('modules', []):
            src = modmap.get('src')
            dst = modmap.get('dest')

            # NOTE(agallagher): calls the `add_source` and `add_resource` below
            # hard-link the given source into the PEX temp dir.  Since OS X and
            # Linux behave different when hard-linking a source that is a
            # symbolic link (Linux does *not* follow symlinks), resolve any
            # layers of symlinks here to get consistent behavior.
            try:
                pex_builder.add_source(dereference_symlinks(src), dst)
            except OSError as err:
                # Maybe we just can't use hardlinks? Try again.
                if not pex_builder._copy:  # pylint: disable=protected-access
                    pex_builder._copy = True  # pylint: disable=protected-access
                    pex_builder.add_source(dereference_symlinks(src), dst)
                else:
                    raise RuntimeError('Failed to add %s: %s' % (src, err))

        # Add resources from the manifest
        for reqmap in manifest.get('resources', []):
            src = reqmap.get('src')
            dst = reqmap.get('dest')
            pex_builder.add_resource(dereference_symlinks(src), dst)

        # Add eggs/wheels from the manifest
        for egg in manifest.get('prebuilt_libs', []):
            try:
                pex_builder.add_dist_location(egg)
            except Exception as err:
                raise RuntimeError('Failed to add %s: %s' % (egg, err))

        pexbin.log('Saving PEX file to %s' % args.pex_name, v=args.verbosity)
        tmp_name = args.pex_name + '~'
        pex.common.safe_delete(tmp_name)
        pex_builder.build(tmp_name)
        os.rename(tmp_name, args.pex_name)


if __name__ == '__main__':
    main()
