load(":toolchain.bzl", "shell_cmd_toolchain")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

shell_cmd_toolchain(
    name = "empty_tc",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "empty",
    toolchain = ":empty_tc",
    toolchain_type = "@bazel_skylib//toolchains/shell_cmd:toolchain_type",
    #toolchain_type = ":toolchain_type",  # TODO yes this must be absolute...
    visibility = ["//visibility:public"],
)
