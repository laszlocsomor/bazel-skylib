load("//rules:shell_action.bzl", "shell_action")

package(default_testonly = 1)

sh_test(
    name = "shell_action_tests",
    srcs = ["shell_action_tests.sh"],
    data = [
        ":sa",
        "//tests:unittest.bash",
    ],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

shell_action(
    name = "sa",
    srcs = [
        "a/bar.txt",
        "a/gen2.txt",
        "foo.txt",
        "gen1.txt",
    ],
    outs = [
        "out1.txt",
        "sa/out2.txt",
    ],
    add_env = {
        "SA_TOOL": "$(location :sa_tool)",
        "SA_OUT1": "$(location out1.txt)",
        "SA_OUT2": "$(location sa/out2.txt)",
        "SA_FOO": "$(location foo.txt)",
        "SA_BAR": "$(location a/bar.txt)",
        "SA_GEN1": "$(location gen1.txt)",
        "SA_GEN2": "$(location a/gen2.txt)",
    },
    cmd = "$SA_TOOL",
    shell = "bash",
    tools = [":sa_tool"],
)

sh_binary(
    name = "sa_tool",
    srcs = ["sa_tool.sh"],
)

genrule(
    name = "gen",
    outs = [
        "gen1.txt",
        "a/gen2.txt",
    ],
    cmd = ("echo 'gen1 file' > $(location gen1.txt) && " +
           "echo 'gen2 file' > $(location a/gen2.txt)"),
)
