licenses(['notice'])

cc_binary(
    name = 'person_cc',
    srcs = [
        'person_main.cc',
    ],
    deps = [
        ':person_cc_proto',
    ],
)

java_binary(
    name = 'person_java',
    srcs = [
        'PersonMain.java',
    ],
    main_class = 'proto_examples.PersonMain',
    deps = [
        ':person_java_proto',
    ],
)

# Convention:
# A java_proto_library that wraps a proto_library named foo_proto
# should be called foo_java_proto.
#
# Note that you only need a java_proto_library for the protos
# you directly use in your code - a java_proto_library converts
# an entire proto graph.
java_proto_library(
    name = "person_java_proto",
    deps = [":person_proto"],
    # FIXME: Why do I have to turn off strict_deps to make it build?
    strict_deps = 0,
)

# Uncomment when the following issue are resolved:
#   https://github.com/google/protobuf/issues/2762
#   https://github.com/google/protobuf/pull/2761
#   https://github.com/google/protobuf/issues/2434 (for javalite)
# java_lite_proto_library(
#     name = "person_java_proto_lite",
#     deps = [":person_proto"],
# )

# Convention:
# A cc_proto_library that wraps a proto_library named foo_proto
# should be called foo_cc_proto.
cc_proto_library(
    name = "person_cc_proto",
    deps = [":person_proto"],
)

# Conventions:
# 1. One proto_library rule per .proto file.
# 2. A file named foo.proto will be in a rule named foo_proto.
proto_library(
    name = "person_proto",
    srcs = ["person.proto"],
    deps = [":address_proto"],
)

proto_library(
    name = "address_proto",
    srcs = ["address.proto"],
    deps = [":zip_code_proto"],
)

proto_library(
    name = "zip_code_proto",
    srcs = ["zip_code.proto"],
)
