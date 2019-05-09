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

load("//lib:dicts.bzl", "dicts")
load(
    "//rules/private:maprule_util.bzl",
    "BASH_STRATEGY",
    "CMD_STRATEGY",
    "resolve_locations",
)

# TODO: test:
# - running a single script
# - running xx_binary with data deps
# - $(location) expansion in args
# - $(location) expansion in env
# - add check: the action generates some outputs or stdout or stderr
# - TODO: replace '/' with '\' in paths on Windows
# - TODO: add a generic toolchain with as_path and run_shell methods (from maprule)

def _impl(ctx):
    if ctx.attr.is_windows:
        strategy = CMD_STRATEGY
    else:
        strategy = BASH_STRATEGY

    tool_inputs, tool_input_mfs = ctx.resolve_tools(tools = [ctx.attr.tool])
    args = resolve_locations(
        ctx,
        strategy,
        {i: ctx.attr.args[i] for i in range(len(ctx.attr.args))},
    )
    envs = resolve_locations(
        ctx,
        strategy,
        {k: v for k, v in ctx.attr.env.items()},
    )
    ctx.actions.run(
        outputs = ctx.outputs.outs,
        inputs = depset(direct = ctx.files.srcs, transitive = [tool_inputs]),
        executable = ctx.executable.tool,
        arguments = [args[i] for i in range(len(args))],
        mnemonic = "RunBinary",
        progress_message = "Running tool",
        use_default_shell_env = False,
        env = dicts.add(ctx.configuration.default_shell_env, envs),
        input_manifests = tool_input_mfs,
    )
    return DefaultInfo(
        files = depset(items = ctx.outputs.outs),
        runfiles = ctx.runfiles(files = ctx.outputs.outs),
    )

_run_binary = rule(
    implementation = _impl,
    attrs = {
        "tool": attr.label(
            executable = True,
            allow_files = True,
            mandatory = True,
            cfg = "host",
        ),
        "env": attr.string_dict(allow_empty = True, mandatory = False),
        "srcs": attr.label_list(allow_empty = True, mandatory = False),
        "outs": attr.output_list(),
        "args": attr.string_list(allow_empty = True, mandatory = False),
        "is_windows": attr.bool(mandatory = True),
    },
)

def run_binary(
        name,
        tool,
        srcs = None,
        outs = None,
        args = None,
        env = None,
        **kwargs):
    _run_binary(
        name = name,
        tool = tool,
        srcs = srcs,
        outs = outs,
        args = args,
        env = env,
        is_windows = select({
            "@bazel_tools//src/conditions:host_windows": True,
            "//conditions:default": False,
        }),
        **kwargs
    )
