#
# Methods for the RGFA class, which allow to handle ordered group lines.
#
module RGFA::Lines::OrderedGroups

  def add_ordered_group(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @ordered_groups << gfa_line
    gfa_line.__set_rgfa(self)
  end
  protected :add_ordered_group

  # Delete an ordered group line from the RGFA object
  # @return [RGFA] self
  # @param ordered_group [RGFA::Line::OrderedGroup] ordered group line instance
  def delete_ordered_group(line)
    @ordered_groups.delete(line)
    return self
  end

  # All ordered_group lines of the graph
  # @return [Array<RGFA::Line::OrderedGroup>]
  def ordered_groups
    @ordered_groups
  end

end
