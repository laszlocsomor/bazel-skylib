# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# """A rule that copies a file to another place.
#
# native.genrule() is sometimes used to copy files (often wishing to rename them).
# The 'copy_file' rule does this with a simpler interface than genrule.
#
# The rule uses a Bash command on Linux/macOS/non-Windows, and a cmd.exe command
# on Windows (no Bash is required).
# """
#
# load(
#     "//rules/private:copy_file_private.bzl",
#     _copy_file = "copy_file",
# )
#
# copy_file = _copy_file

load("//lib:dicts.bzl", "dicts")

_TC_TYPE = "@bazel_skylib//toolchains/shell_cmd:toolchain_type"

def _win_path(p):
    return p.replace("/", "\\")

def _expand_env(ctx, use_backslashes):
    # PERFORMANCE WARNING: As of 2019-07-17 (Bazel 0.28.0), ctx.expand_location creates a new
    # ImmutableMap of all expandable labels, so the cost here is quadratic.
    exp = ctx.expand_location("&&".join(["$(location %s)" % v for v in ctx.attr.env.values()])).split("&&")
    if len(exp) != len(ctx.attr.env):
        fail("TODO")
    i = 0
    res = {}
    for k in ctx.attr.env.keys():
        res[k] = _win_path(exp[i]) if use_backslashes else exp[i]
        i += 1
    return res

def _bash_action(ctx, abs_bash_path, outs, tools_inputs, tools_manifests):
    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = script,
        content = ("#!%s\n" % abs_bash_path) + ctx.attr.bash_cmd,
        is_executable = True,
    )
    ctx.actions.run(
        inputs = ctx.files.srcs + tools_inputs,
        outputs = outs,
        executable = abs_bash_path,
        arguments = ["-c", script.path],
        tools = [script] + tools_inputs,
        env = dicts.add(ctx.configuration.default_shell_env, _expand_env(ctx, False)),
        input_manifests = tools_manifests,
    )

def _ps_action(ctx, outs, tools_inputs, tools_manifests):
    script = ctx.actions.declare_file(ctx.label.name + ".ps1")
    ctx.actions.write(output = script, content = ctx.attr.ps_cmd, is_executable = True)
    ctx.actions.run(
        inputs = ctx.files.srcs + tools_inputs,
        outputs = outs,
        executable = "powershell.exe",
        arguments = ["-NoLogo", "-NonInteractive", _win_path(script.path)],
        tools = [script] + tools_inputs,
        env = dicts.add(ctx.configuration.default_shell_env, _expand_env(ctx, False)),
        input_manifests = tools_manifests,
    )

def _cmd_action(ctx, outs, tools_inputs, tools_manifests):
    script = ctx.actions.declare_file(ctx.label.name + ".bat")
    ctx.actions.write(output = script, content = ctx.attr.cmd_cmd, is_executable = True)
    ctx.actions.run(
        inputs = ctx.files.srcs + tools_inputs,
        outputs = outs,
        executable = "cmd.exe",
        arguments = ["/C", _win_path(script.path)],
        tools = [script] + tools_inputs,
        env = dicts.add(ctx.configuration.default_shell_env, _expand_env(ctx, False)),
        input_manifests = tools_manifests,
    )

def _common_impl(ctx, is_executable, outs):
    tc = ctx.toolchains[_TC_TYPE].shell_cmd_info
    if not tc.bash_path and not tc.ps_present and not tc.cmd_present:
        fail("No registered toolchain of type \"%s\" defines suitable shells." % _TC_TYPE)
    if ctx.attr.tools:
        tools_inputs, tools_manifests = ctx.resolve_tools(ctx.attr.tools)
    else:
        tools_inputs, tools_manifests = [], []
    if ctx.attr.bash_cmd and tc.bash_path:
        _bash_action(ctx, tc.bash_path, outs, tools_inputs, tools_manifests)
    elif ctx.attr.ps_cmd and tc.ps_present:
        _ps_action(ctx, outs, tools_inputs, tools_manifests)
    elif ctx.attr.cmd_cmd and tc.cmd_present:
        _cmd_action(ctx, outs, tools_inputs, tools_manifests)
    else:
        fail("No suitable toolchain found.")
    files = depset(direct = outs)
    runfiles = ctx.runfiles(files = outs)
    if is_executable:
        return [DefaultInfo(files = files, runfiles = runfiles, executable = outs[0])]
    else:
        return [DefaultInfo(files = files, runfiles = runfiles)]

def _impl(ctx):
    return _common_impl(ctx, False, ctx.outputs.outs)

def _ximpl(ctx):
    return _common_impl(ctx, True, [ctx.outputs.out])

_ATTRS = {
    "srcs": attr.label_list(allow_files = True),
    "tools": attr.label_list(allow_files = True, cfg = "host"),
    "bash_cmd": attr.string(),
    "ps_cmd": attr.string(),
    "cmd_cmd": attr.string(),
    "env": attr.string_dict(),
}

_shell_cmd = rule(
    implementation = _impl,
    attrs = dicts.add(
        _ATTRS,
        {"outs": attr.output_list(mandatory = True)},
    ),
    toolchains = [_TC_TYPE],
)

_shell_xcmd = rule(
    implementation = _ximpl,
    executable = True,
    attrs = dicts.add(
        _ATTRS,
        {"out": attr.output(mandatory = True)},
    ),
    toolchains = [_TC_TYPE],
)

def shell_cmd(name, is_executable = False, out = None, outs = None, **kwargs):
    if not kwargs.get("bash_cmd") and not kwargs.get("ps_cmd") and not kwargs.get("cmd_cmd"):
        fail("TODO")
    if is_executable:
        if outs or not out:
            fail("TODO")
        _shell_xcmd(
            name = name,
            out = out,
            **kwargs
        )
    else:
        if out or not outs:
            fail("TODO")
        _shell_cmd(
            name = name,
            outs = outs,
            **kwargs
        )
