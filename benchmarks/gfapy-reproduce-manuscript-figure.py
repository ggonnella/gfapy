#!/usr/bin/env python3
"""
Run the benchmarks necessary to reproduce the figures of Section 3
of the Supplementary Information of the manuscript \"Gfapy: a flexible
and extensible software library for handling sequence graphs in Python\"
and plots the figures using R.
"""

import argparse
import os

op = argparse.ArgumentParser(description=__doc__)
op.add_argument("fignum", help="Figure number", type=int,
    choices=range(5,9))
op.add_argument("--queue", default=None,
    help="Use the specified queue of a Grid Engine cluster system "+
    "(e.g. 16c.q). If not provided, the benchmarks are run on the "+
    "local computer.")
op.add_argument("--nrepl",type=int, default=3,
    help="Number of replicates (default: 3)")
op.add_argument("--fast",action="store_true",
    help="Run only the three fastest datapoints of the benchmark")
opts = op.parse_args()

if opts.fignum == 5:
  testvar="segments"
  operation="convert"
elif opts.fignum == 6:
  testvar="connectivity"
  operation="convert"
elif opts.fignum == 7:
  testvar="segments"
  operation="mergelinear"
else: # 8
  testvar="connectivity"
  operation="mergelinear"

if opts.fast:
  subset="fast"
else:
  subset="all"

run_benchmarks_args="figure{}.out {} gfa2 {} {} {}".format(
    opts.fignum, operation, testvar, subset, opts.nrepl)

if not opts.queue:
  os.system("./gfapy-run-benchmarks.sh {}".format(run_benchmarks_args))
else:
  qsub_script_pfx=\
"""#!/bin/bash
#$ -clear
#$ -q {}
#$ -cwd
#$ -V
#$ -S /bin/bash
#$ -o jobs_out
#$ -j y
#$ -sync y

""".format(opts.queue)
  with open("gfapy-run-benchmarks.sh", "r") as input_file:
    content = input_file.read()
  with open("gfapy-run-benchmarks.qsub", "w") as output_file:
    output_file.write(qsub_script_pfx)
    output_file.write(content)
  os.system("mkdir -p jobs_out")
  os.system("qsub gfapy-run-benchmarks.qsub {}".format(run_benchmarks_args))

if testvar == "segments":
  prepareflag=""
else:
  prepareflag="--mult"
os.system("./gfapy-plot-preparedata.py {} figure{}.out > figure{}.dat".format(
  prepareflag, opts.fignum, opts.fignum))
os.system("./gfapy-plot-benchmarkdata.R figure{}.dat figure{} {}".format(
  opts.fignum, opts.fignum, testvar))
