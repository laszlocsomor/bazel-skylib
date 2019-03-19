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

"""Implementation of shell_action rule."""

load(
    "//rules:maprule_util.bzl",
    "BASH_STRATEGY",
    "CMD_STRATEGY",
    "resolve_locations",
)

# TODO(laszlocsomor):
# - implement attribute checks
# - implement rule that can create executable output (outs must be restricted to 1)
# - add documentation and comments

def _impl(ctx):
    strategy = CMD_STRATEGY if ctx.attr.shell == "cmd" else BASH_STRATEGY

    inputs_from_tools, manifests_from_tools = ctx.resolve_tools(tools = ctx.attr.tools)

    strategy.create_action(
        ctx,
        outputs = ctx.outputs.outs,
        command = ctx.attr.cmd,
        inputs = depset(direct = ctx.files.srcs, transitive = [inputs_from_tools]),
        env = resolve_locations(ctx, strategy, ctx.attr.add_env),
        progress_message = "Executing shell action",
        mnemonic = "ShellAction",
        manifests_from_tools = manifests_from_tools,
    )

    return DefaultInfo(
        files = depset(direct = ctx.outputs.outs),
        runfiles = ctx.runfiles(files = ctx.outputs.outs),
    )

shell_action = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = True,
            allow_files = True,
            mandatory = False,
        ),
        "outs": attr.output_list(
            allow_empty = False,
            mandatory = True,
        ),
        "tools": attr.label_list(
            allow_empty = True,
            allow_files = False,
            mandatory = False,
            cfg = "host",
        ),
        "add_env": attr.string_dict(
            allow_empty = True,
            mandatory = False,
        ),
        "shell": attr.string(
            mandatory = True,
            values = ["cmd", "bash"],
        ),
        "cmd": attr.string(
            mandatory = True,
        ),
    },
)
