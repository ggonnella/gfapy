#!/usr/bin/env ruby
require "rgfa"

mem = ARGV.delete("--mem")
if mem
  require "memory_profiler"
  profklass = MemoryProfiler
  proflabel = "memory"
  profmethod = :report
  printer = lambda do |result|
    result.pretty_print
  end
else
  require "ruby-prof"
  profklass = RubyProf
  proflabel = "running time"
  profmethod = :profile
  printer = lambda do |result|
    RubyProf::FlatPrinter.new(result).print(STDOUT)
  end
end

merge = ARGV.delete("--merge")

if ARGV.size != 1
  STDERR.puts "Running time and memory profiler for RGFA"
  STDERR.puts
  STDERR.puts "Usage: #$0 [options] <gfafile>"
  STDERR.puts
  STDERR.puts "The default action is to parse the GFA file and output it again"
  STDERR.puts "(to /dev/null). This can be changed using the following options."
  STDERR.puts
  STDERR.puts "Actions:"
  STDERR.puts "  --merge: merge linear paths"
  STDERR.puts
  STDERR.puts "Profiling options:"
  STDERR.puts "  --mem: memory profiling (default: running time profiling)"
  exit 1
end

actions = ["parse input file", "output GFA to /dev/null"]
if merge
  actions.insert(1, "merge linear paths")
end

filename = ARGV[0]

puts "# --- RGFA profiler ---"
puts "# Input file: #{filename}"
puts "# Profiling: #{proflabel}"
puts "# Actions: #{actions.join(", ")}"
puts "# ---"
puts

result = profklass.send(profmethod) do
  g = RGFA.new
  g.enable_progress_logging(part: 0.001)
  g.read_file(filename)
  if merge
    g.merge_linear_paths
  end
  g.to_file("/dev/null")
end
printer.call(result)
