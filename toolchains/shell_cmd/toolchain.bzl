ShellCmdInfo = provider(
    fields = ["bash_path", "ps_present", "cmd_present"],
)

def _impl(ctx):
    return [platform_common.ToolchainInfo(
        shell_cmd_info = ShellCmdInfo(
            bash_path = ctx.attr.bash_path,
            ps_present = ctx.attr.ps_present,
            cmd_present = ctx.attr.cmd_present,
        ),
    )]

shell_cmd_toolchain = rule(
    implementation = _impl,
    attrs = {
        "bash_path": attr.string(),
        "ps_present": attr.string(),
        "cmd_present": attr.string(),
    },
)
