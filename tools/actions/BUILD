py_binary(
  name = 'generate_compile_command',
  srcs = [
    'generate_compile_command.py',
  ],
  deps = [
    ':extra_actions_proto_py',
  ],
)

py_library(
    name = 'extra_actions_proto_py',
    srcs = [
        'extra_actions_base_pb2.py',
    ],
)

action_listener(
  name = 'generate_compile_commands_listener',
  visibility = ['//visibility:public'],
  mnemonics = [
    'CppCompile',
  ],
  extra_actions = [':generate_compile_commands_action'],
)

extra_action(
  name = 'generate_compile_commands_action',
  tools = [
    ':generate_compile_command',
  ],
  out_templates = [
    '$(ACTION_ID)_compile_command',
  ],
  cmd = '$(location :generate_compile_command) $(EXTRA_ACTION_FILE)' +
        ' $(output $(ACTION_ID)_compile_command)',
)
