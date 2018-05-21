load('@io_bazel_rules_docker//java:image.bzl', 'java_image')

java_image(
    name = 'helloworld_image',
    visibility = [
        '//visibility:public',
    ],
    srcs = [
        'HelloWorld.java',
    ],
    main_class = 'com.logi.examples.java.HelloWorld',
)
