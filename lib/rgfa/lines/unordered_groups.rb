#
# Methods for the RGFA class, which allow to handle unordered group lines.
#
module RGFA::Lines::UnorderedGroups

  # All unordered_group lines of the graph
  # @return [Array<RGFA::Line::UnorderedGroup>]
  def unordered_groups
    @records[:U].values.flatten
  end

end
