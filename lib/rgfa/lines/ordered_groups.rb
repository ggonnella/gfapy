#
# Methods for the RGFA class, which allow to handle ordered group lines.
#
module RGFA::Lines::OrderedGroups

  # All ordered_group lines of the graph
  # @return [Array<RGFA::Line::OrderedGroup>]
  def ordered_groups
    @records[:O].values.flatten
  end

end
