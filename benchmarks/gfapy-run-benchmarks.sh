#!/bin/bash

if [ $# -ne 6 ]; then
  echo "Usage: $0 <outfile> <operation> <version> <variable> <range> <nrepl>" > /dev/stderr
  echo "  outfile: will be overwritten if exists" > /dev/stderr
  echo "  operation: (mergelinear/convert) ../bin/gfapy-<operation> <gfafile> will be called" > /dev/stderr
  echo "  version: (gfa1/gfa2) gfa version" > /dev/stderr
  echo "  variable: (segments/connectivity)" > /dev/stderr
  echo "  range: (all/fast/slow)" > /dev/stderr
  echo "  nrepl: (e.g. 3) number of replicates" > /dev/stderr
  exit 1
fi

outfile=$1
operation=$2
version=$3
variable=$4
range=$5
nrepl=$6

if [ $variable == "segments" ]; then
  if [ $range == "fast" ]; then
    nsegments="1000 2000 4000"
  elif [ $range == "slow" ]; then
    nsegments="8000 16000 32000 64000 128000 256000 512000 1024000 2048000"
  elif [ $range == "all"]; then
    nsegments="1000 2000 4000 8000 16000 32000 64000 128000 256000 512000 1024000 2048000"
  fi
else
  nsegments=4000
fi

if [ $variable == "connectivity" ]; then
  if [ $range == "fast" ]; then
    multipliers="2 4 8"
  elif [ $range == "slow" ]; then
    multipliers="16 32 64 128 256"
  elif [ $range == "all"]; then
    multipliers="2 4 8 16 32 64 128 256"
  fi
else
  multipliers=2
fi

mkdir -p benchmark_results
rm -f $outfile
echo "# hostname: $HOSTNAME" > $outfile
echo "### benchmark data:" >> $outfile
for ((replicate=1;replicate<=nrepl;++replicate)); do
  for i in $nsegments; do
    for m in $multipliers; do
      fname="benchmark_results/${i}_e${m}x.$replicate.${version}"
      bmout="$fname.$operation.benchmark"
      rm -f $bmout
      if [ ! -e $fname ]; then
        ./gfapy-randomgraph --segments $i -g $version \
          --dovetails-per-segment $m  --with-sequence > $fname
      fi
      ./gfapy-benchmark-collectdata ../bin/gfapy-$operation $fname \
                                    1> /dev/null 2> $bmout
      elapsed=$(grep -P -o "(?<=) [^ ]*(?=elapsed)" $bmout)
      memory=$(grep -P -o "(?<=VmHWM: ).*" $bmout)
      filesize=( $(ls -ln $fname) );filesize=${filesize[4]}
      echo -e "gfapy-$operation\t$version\t$i\t$m\t$replicate\t$elapsed\t$memory\t$filesize" >> $outfile
    done
  done
done
