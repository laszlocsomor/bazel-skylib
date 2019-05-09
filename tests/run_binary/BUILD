load("//rules:diff_test.bzl", "diff_test")
load("//rules:run_binary.bzl", "run_binary")
load("//rules:write_file.bzl", "write_file")

diff_test(
    name = "run_script_test",
    file1 = ":run_script.out",
    file2 = ":run_script_expected",
)

run_binary(
    name = "run_script",
    outs = ["run_script.out"],
    args = [
        "$(location run_script.out)",
        "a",
        "",
        "\"b \\\"c",
        "z",
    ],
    env = {
        "ENV1": "ab/cd \\\"ef",
        "OUT": "$(location run_script.out)",
    },
    tool = select({
        "@bazel_tools//src/conditions:host_windows": ":script_bat",
        "//conditions:default": ":script_sh",
    }),
)

# Generate this file with write_file instead of checking it in to the source
# tree. This ensures line endings are consistent across "run_script.expected"
# and "run_script.out".
write_file(
    name = "run_script_expected",
    out = "run_script.expected",
    content = [
        "ENV1=(ab/cd \\\"ef)",
        # Can't prevent "echo" adding a newline on Windows, so let's add one to
        "arg2=(a)",
        "arg3=()",
        "arg4=(\"b \\\"c)",
        "arg5=(z)",
        # the expected output too.
        "",
    ],
)

write_file(
    name = "script_bat",
    out = "script.bat",
    content = [
        "@echo>\"%OUT%\" ENV1=(%ENV1%)",
        "@echo>>\"%OUT%\" arg2=(%2)",
        "@echo>>\"%OUT%\" arg3=(%3)",
        "@echo>>\"%OUT%\" arg4=(%4)",
        "@echo>>\"%OUT%\" arg5=(%5)",
    ],
    is_executable = True,
)

write_file(
    name = "script_sh",
    out = "script.sh",
    content = [
        "#!/bin/bash",
        "echo \"ENV1=(${ENV1:-})\" > \"$OUT\"",
        "echo \"arg2=(${2:-})\" >> \"$OUT\"",
        "echo \"arg3=(${3:-})\" >> \"$OUT\"",
        "echo \"arg4=(${4:-})\" >> \"$OUT\"",
        "echo \"arg5=(${5:-})\" >> \"$OUT\"",
    ],
    is_executable = True,
)

diff_test(
    name = "run_bin_test",
    file1 = ":run_bin.out",
    file2 = ":run_bin_expected",
)

run_binary(
    name = "run_bin",
    outs = ["run_bin.out"],
    args = [
        "$(location run_bin.out)",
        "a",
        "",
        "\"b \\\"c",
        "z",
    ],
    env = {"ENV2": "xx/yy \\\"zz"},
    tool = ":bin",
)

write_file(
    name = "run_bin_expected",
    out = "run_bin_expected.txt",
    content = ["ENV2=(xx/yy \\\"zz)|a||\"b \\\"c|z|foo|bar"],
)

py_binary(
    name = "bin",
    srcs = ["bin.py"],
    data = [":gen-data"],
    deps = ["@bazel_tools//tools/python/runfiles"],
)

write_file(
    name = "gen-data",
    out = "data.txt",
    content = [
        "foo",
        "bar",
    ],
)
