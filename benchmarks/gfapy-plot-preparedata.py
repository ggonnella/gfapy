#!/usr/bin/env python3
"""
Prepare the output of the convert benchmark script for the R plotting script.
"""

import argparse
import os
import sys
import re

op = argparse.ArgumentParser(description=__doc__)
op.add_argument('--version', action='version', version='%(prog)s 1.0')
op.add_argument("--mult", "-m", action="store_true",
    help="set if variable n of edges/segment")
op.add_argument("inputfile")
opts = op.parse_args()

if not os.path.exists(opts.inputfile):
  sys.stderr.write("Input file not found: {}\n".format(opts.inputfile))
  exit(1)

with open(opts.inputfile) as inputfile:
  header = True
  if opts.mult:
    outdata = ["mult", "time", "space", "time_per_line", "space_per_line"]
  else:
    outdata = ["lines", "time", "space", "time_per_line", "space_per_line"]
  print("\t".join(outdata))
  for line in inputfile:
    if line[:3] == "###":
      header = False
    elif not header:
      data = line.rstrip("\n\r").split("\t")
      n_segments = data[2]
      multiplier = data[3]
      n_lines = int(int(n_segments) * (1+float(multiplier)))
      elapsed = data[5]
      elapsed_match = re.compile(r'\s+(\d+):(\d+\.\d+)').match(elapsed)
      if elapsed_match:
        minutes = int(elapsed_match.groups()[0])
        seconds = float(elapsed_match.groups()[1])
        seconds += minutes * 60
      else:
        elapsed_match = re.compile(r'\s+(\d+):(\d+):(\d+)').match(elapsed)
        if elapsed_match:
          hours = int(elapsed_match.groups()[0])
          minutes = int(elapsed_match.groups()[1])
          seconds = int(elapsed_match.groups()[2])
          minutes += hours * 60
          seconds += minutes * 60
        else:
          continue
      memory = data[6]
      memory = int(re.compile(r'(\d+) kB').match(memory).groups()[0])
      megabytes = memory / 1024
      if opts.mult:
        outdata = [str(multiplier)]
      else:
        outdata = [str(n_lines)]
      outdata += [str(seconds),str(megabytes),
                  str(seconds/n_lines), str(megabytes/n_lines)]
      print("\t".join(outdata))
