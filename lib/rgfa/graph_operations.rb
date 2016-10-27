#
# Complicated operations on the graph, such as identification and merging of
# linear paths, multiplication of segments, analysis of the connectivity of
# the graph are defined in submodules of this module and included in the RGFA
# class.
#
RGFA::GraphOperations = Module.new

require_relative "graph_operations/connectivity.rb"
require_relative "graph_operations/linear_paths.rb"
require_relative "graph_operations/multiplication.rb"

module RGFA::GraphOperations
  include RGFA::GraphOperations::Connectivity
  include RGFA::GraphOperations::LinearPaths
  include RGFA::GraphOperations::Multiplication
end
