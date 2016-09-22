#!/usr/bin/env ruby
require "rgfatools"

if ARGV.size != 1
  STDERR.puts "Usage: #$0 <gfa>"
  exit 1
end

gfa = RGFA.new
gfa.enable_progress_logging(part: 0.01)
gfa.turn_off_validations
gfa.read_file(ARGV[0])
gfa.merge_linear_paths(disable_tracking: true, merged_name: :short)
puts gfa
