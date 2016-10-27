#
# Methods for the RGFA class, which allow to handle gap lines.
#
module RGFA::Lines::Gaps

  def add_gap(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @gaps << gfa_line
  end
  protected :add_gap

  # Delete a gap line from the RGFA object
  # @return [RGFA] self
  # @param gap [RGFA::Line::Gap] gap line instance
  def delete_gap(line)
    @gaps.delete(line)
    return self
  end

  # All gap lines of the graph
  # @return [Array<RGFA::Line::Gap>]
  def gaps
    @gaps
  end

end
