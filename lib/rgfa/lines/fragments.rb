#
# Methods for the RGFA class, which allow to handle fragment lines.
#
module RGFA::Lines::Fragments

  def add_fragment(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @fragments << gfa_line
    gfa_line.__set_rgfa(self)
  end
  protected :add_fragment

  # Delete a fragment line from the RGFA object
  # @return [RGFA] self
  # @param fragment [RGFA::Line::Fragment] fragment line instance
  def delete_fragment(line)
    @fragments.delete(line)
    return self
  end

  # All fragment lines of the graph
  # @return [Array<RGFA::Line::Fragment>]
  def fragments
    @fragments
  end

end
