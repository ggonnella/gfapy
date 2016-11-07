#
# Methods for the RGFA class, which allow to handle gap lines.
#
module RGFA::Lines::Gaps

  # All gap lines of the graph
  # @return [Array<RGFA::Line::Gap>]
  def gaps
    @records[:G].values.flatten
  end

end
