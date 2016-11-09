#
# Methods for the RGFA class, which allow to handle edge lines.
#
module RGFA::Lines::Edges

  # All edge lines of the graph
  # @return [Array<RGFA::Line::Edge::GFA2>]
  def edges
    @records[:E].values.flatten
  end

end
