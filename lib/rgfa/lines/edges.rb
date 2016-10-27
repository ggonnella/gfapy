#
# Methods for the RGFA class, which allow to handle edge lines.
#
module RGFA::Lines::Edges

  def add_edge(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @edges << gfa_line
  end
  protected :add_edge

  # Delete a edge line from the RGFA object
  # @return [RGFA] self
  # @param edge [RGFA::Line::Edge] edge line instance
  def delete_edge(line)
    @edges.delete(line)
    return self
  end

  # All edge lines of the graph
  # @return [Array<RGFA::Line::Edge>]
  def edges
    @edges
  end

end
