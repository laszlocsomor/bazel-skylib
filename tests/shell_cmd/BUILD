load("//rules:shell_cmd.bzl", "shell_cmd")

shell_cmd(
    name = "foo",
    bash_cmd = "echo 'hello bash' > \"$OUT\"",
    ps_cmd = "'hello ps' | out-file \"$env:OUT\"",
    cmd_cmd = "echo 'hello cmd' > \"%OUT%\"",
    outs = ["hello.txt"],
    env = {"OUT": "hello.txt"},
)
