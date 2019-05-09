from bazel_tools.tools.python.runfiles import runfiles
import os
import sys

r = runfiles.Create()
if not r:
  raise Exception("Could not initialize runfiles")
with open(sys.argv[1], "wt") as dst:
  dst.write("ENV2=(%s)" % os.environ.get("ENV2"))
  with open(r.Rlocation("bazel_skylib/tests/run_binary/data.txt"), "rt") as src:
    dst.write("".join(line.strip() for line in src.readlines()))
