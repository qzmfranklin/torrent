workspace(name = 'torrent')

load('//bazel:workspace.bzl', torrent_repositories = 'repositories')
torrent_repositories()

## Load the Go toolchain.
#load('@io_bazel_rules_go//go:def.bzl', 'go_rules_dependencies',
     #'go_register_toolchains')
#go_rules_dependencies()
#go_register_toolchains()

## Enable protobuf and grpc support for Go.
## TODO (zhongming): Remove this once go_rules is upgraded to 0.8.0.  Currently
## that is pending a bug:
##       https://github.com/bazelbuild/buildtools/issues/174
#load('@io_bazel_rules_go//proto:def.bzl', 'proto_register_toolchains')
#proto_register_toolchains()

# Enable PythonPex.
load('@io_bazel_rules_pex//pex:pex_rules.bzl', 'pex_repositories')
pex_repositories()

## TODO (zhongming): Remove bind() after including buildtools into
## third_party/go/
#bind(
    #name = 'buildifier',
    #actual = '@com_github_bazelbuild_buildtools//buildifier',
#)

## Enable skydoc, building HTML and Markdown documents from .bzl files.
#load('@io_bazel_rules_sass//sass:sass.bzl', 'sass_repositories')
#sass_repositories()
#load('@io_bazel_skydoc//skylark:skylark.bzl', 'skydoc_repositories')
#skydoc_repositories()
