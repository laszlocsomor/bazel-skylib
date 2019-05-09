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
    args = ["$(location run_script.out)"],
    #        "macko",
    #        "",                 #   \"\"
    #        " ",                #   \" \"
    #        "\"",               #   \"\\\"\"
    #        "\"\\",             #   \"\\\"\\\\\"
    #        "\\",               #   \\
    #        "\\\"",             #   \"\\\\\\\"\"
    #        "with space",       #   \"with space\"
    #        "with^caret",       #   with^caret
    #        "space ^caret",     #   \"space ^caret\"
    #        "caret^ space",     #   \"caret^ space\"
    #        "with\"quote",      #   \"with\\\"quote\"
    #        "with\\backslash",  #   with\\backslash
    #        "one\\ backslash and \\space",       #   \"one\\ backslash and \\space\"
    #        "two\\\\backslashes",                #   two\\\\backslashes
    #        "two\\\\ backslashes \\\\and space", #   \"two\\\\ backslashes \\\\and space\"
    #        "one\\\"x",         #   \"one\\\\\\\"x\"
    #        "two\\\\\"x",       #   \"two\\\\\\\\\\\"x\"
    #        "a \\ b",           #   \"a \\ b\"
    #        "a \\\" b",         #   \"a \\\\\\\" b\"
    #        "A",                #   A
    #        "\"a\"",            #   \"\\\"a\\\"\"
    #        "B C",              #   \"B C\"
    #        "\"b c\"",          #   \"\\\"b c\\\"\"
    #        "D\"E",             #   \"D\\\"E\"
    #        "\"d\"e\"",         #   \"\\\"d\\\"e\\\"\"
    #        "C:\\F G",          #   \"C:\\F G\"
    #        "\"C:\\f g\"",      #   \"\\\"C:\\f g\\\"\"
    #        "C:\\H\"I",         #   \"C:\\H\\\"I\"
    #        "\"C:\\h\"i\"",     #   \"\\\"C:\\h\\\"i\\\"\"
    #        "C:\\J\\\"K",       #   \"C:\\J\\\\\\\"K\"
    #        "\"C:\\j\\\"k\"",   #   \"\\\"C:\\j\\\\\\\"k\\\"\"
    #        "C:\\L M ",         #   \"C:\\L M \"
    #        "\"C:\\l m \"",     #   \"\\\"C:\\l m \\\"\"
    #        "C:\\N O\\",        #   \"C:\\N O\\\\\"
    #        "\"C:\\n o\\\"",    #   \"\\\"C:\\n o\\\\\\\"\"
    #        "C:\\P Q\\ ",       #   \"C:\\P Q\\ \"
    #        "\"C:\\p q\\ \"",   #   \"\\\"C:\\p q\\ \\\"\"
    #        "C:\\R\\S\\",       #   C:\\R\\S\\
    #        "C:\\R x\\S\\",     #   \"C:\\R x\\S\\\\\"
    #        "\"C:\\r\\s\\\"",   #   \"\\\"C:\\r\\s\\\\\\\"\"
    #        "\"C:\\r x\\s\\\"", #   \"\\\"C:\\r x\\s\\\\\\\"\"
    #        "C:\\T U\\W\\",     #   \"C:\\T U\\W\\\\\"
    #        "\"C:\\t u\\w\\\"", #   \"\\\"C:\\t u\\w\\\\\\\"\"
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
    # Can't prevent "echo" adding a newline on Windows, so let's add one to the
    # expected output too.
    content = [
        "ENV1=(ab/cd \\\"ef)",
        "",
    ],
)

write_file(
    name = "script_bat",
    out = "script.bat",
    content = ["@echo>\"%OUT%\" ENV1=(%ENV1%)"],
    is_executable = True,
)

write_file(
    name = "script_sh",
    out = "script.sh",
    content = [
        "#!/bin/bash",
        "echo \"ENV1=(${ENV1:-})\" > \"$OUT\"",
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
    args = ["$(location run_bin.out)"],
    env = {"ENV2": "xx/yy \\\"zz"},
    tool = ":bin",
)

write_file(
    name = "run_bin_expected",
    out = "run_bin_expected.txt",
    content = ["ENV2=(xx/yy \\\"zz)foobar"],
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
