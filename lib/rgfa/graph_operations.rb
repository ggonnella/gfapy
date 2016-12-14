#
# Complicated operations on the graph, such as identification and merging of
# linear paths, multiplication of segments, analysis of the connectivity of
# the graph are defined in submodules of this module and included in the RGFA
# class.
#
RGFA::GraphOperations = Module.new

require_relative "graph_operations/topology.rb"
require_relative "graph_operations/linear_paths.rb"
require_relative "graph_operations/multiplication.rb"
require_relative "graph_operations/rgl.rb"

module RGFA::GraphOperations
  include RGFA::GraphOperations::Topology
  include RGFA::GraphOperations::LinearPaths
  include RGFA::GraphOperations::Multiplication
  include RGFA::GraphOperations::RGL
end
