# This package contains the pre-commit hooks, which, by definition are public.
package(default_visibility=['//visibility:public'])

py_library(
    name = 'remove_modeline',
    srcs = [
        'remove_modeline.py',
    ],
)

py_test(
    name = 'remove_modeline_test',
    srcs = [
        'remove_modeline_test.py',
    ],
    deps = [
        ':remove_modeline',
    ],
    size = 'small',
)

py_library(
    name = 'purify_text',
    srcs = [
        'purify_text.py',
    ],
)

py_test(
    name = 'purify_text_test',
    srcs = [
        'purify_text_test.py',
    ],
    deps = [
        ':purify_text',
    ],
    size = 'small',
)
