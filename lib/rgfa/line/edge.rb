# An edge line is an E line of a GFA2 file
# or a L/C line of a GFA1 file
class RGFA::Line::Edge < RGFA::Line
end
require_relative "edge/gfa2.rb"
require_relative "edge/link.rb"
require_relative "edge/containment.rb"
