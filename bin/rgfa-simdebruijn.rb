#!/usr/bin/env ruby
require "rgfatools"
require "set"

def read_sequences(filename, logger)
  file = File.new(filename)
  sequences = []
  linecount = `wc -l #{filename}`.strip.split(" ")[0].to_i
  logger.progress_init(:read_file, "lines", linecount,
                    "Parse sequences from file with #{linecount} lines")
  file.each do |line|
    if line[0]==">"
      sequences << ""
    else
      sequences.last << line.chomp
    end
    logger.progress_log(:read_file)
  end
  logger.progress_end(:read_file)
  file.close
  return sequences
end

if ARGV.size != 2
  STDERR.puts "Usage: #$0 <k> <genome.fas>"
  exit 1
end

k = Integer(ARGV[0])

logger = RGFA::Logger.new()
logger.enable_progress(part: 0.1)
sequences = read_sequences(ARGV[1], logger)
logger.log("Sequence lengths (nt): #{sequences.map(&:size)}")
segments = {}
links = Set.new
kmercount = sequences.map{|seq|seq.length-k+1}.inject(:+)
logger.progress_init(:generate_graph, "kmers", kmercount,
                    "Create graph from #{kmercount} kmers")
i=1
sequences.each do |seq|
  0.upto(seq.length-k) do |pos|
    kmer = seq[pos..(pos+k-1)].downcase
    prefix = kmer[0..k-2]
    suffix = kmer[1..k-1]
    link = "L"
    [prefix, suffix].each do |km1mer|
      orient = "+"
      km1mer_rc = km1mer.rc
      if km1mer > km1mer_rc
        km1mer = km1mer_rc
        orient = "-"
      end
      s = segments[km1mer.to_sym]
      if s.nil?
        s = [i,0]
        segments[km1mer.to_sym] = s
        i+=1;
      end
      s[1] += 1
      link << "\t#{s[0]}\t#{orient}"
    end
    link << "\t#{k-2}M"
    links << link
    logger.progress_log(:generate_graph, segments_added: i,
                        links_added: links.size)
  end
end
logger.progress_end(:generate_graph)
segmentscount = i-1
linkscount = links.size
puts "H\tks:i:#{k}"
logger.progress_init(:write_segments, "segments", segmentscount,
                     "Output #{segmentscount} segments")
segments.each do |km1mer, data|
  puts "S\t#{data[0]}\t#{km1mer}\tKC:i:#{data[1]}"
  logger.progress_log(:write_segments)
end
logger.progress_end(:write_segments)
logger.progress_init(:write_links, "links", linkscount,
                     "Output #{linkscount} links")
links.each do |link|
  puts link
  logger.progress_log(:write_links)
end
logger.progress_end(:write_links)
