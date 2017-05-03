#!/bin/bash
#$ -clear
#$ -q 16c.q
#$ -cwd
#$ -V
#$ -S /bin/bash
#$ -o jobs_out
#$ -j y

if [ $# -ne 4 ]; then
  echo "Usage: $0 <operation> <version> <variable> <range>" > /dev/stderr
  echo "  operation: (mergelinear/convert) ../bin/gfapy-<operation> <gfafile> will be called" > /dev/stderr
  echo "  version: (gfa1/gfa2) gfa version" > /dev/stderr
  echo "  variable: (segments/connectivity)" > /dev/stderr
  echo "  range: (all/fast/slow)" > /dev/stderr
  exit 1
fi

operation=$1
version=$2
variable=$3
range=$4

if [ $variable == "segments" ]; then
  if [ $range == "fast" ]; then
    nsegments="1000 2000 4000 8000 16000 32000 64000 128000"
  elif [ $range == "slow" ]; then
    nsegments="256000 512000 1024000 2048000 4096000"
  elif [ $range == "all"]; then
    nsegments="1000 2000 4000 8000 16000 32000 64000 128000 256000 512000 1024000 2048000 4096000"
  fi
else
  nsegments=4000
fi

if [ $variable == "connectivity" ]; then
  if [ $range == "fast" ]; then
    multipliers="2 4 8 16 32 64"
  elif [ $range == "slow" ]; then
    multipliers="128 256"
  elif [ $range == "all"]; then
    multipliers="2 4 8 16 32 64 128 256"
  fi
else
  multipliers=2
fi

replicate=1
for i in $nsegments; do
  for m in $multipliers; do
    fname="${i}_e${m}x.$replicate.${version}"
    if [ ! -e $fname ]; then
      ./gfapy-randomgraph --segments $i -g $version \
        --dovetails-per-segment $m  --with-sequence > $fname
    fi
    echo "Profiling $operation $fname ..."
    rm -f $fname.$operation.prof
    python3 -m cProfile -o $fname.$operation.prof \
      ../bin/gfapy-$operation $fname 1> /dev/null
  done
done
