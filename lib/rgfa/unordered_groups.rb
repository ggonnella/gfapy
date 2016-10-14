require_relative "error"

#
# Methods for the RGFA class, which allow to handle unordered group lines.
#
module RGFA::UnorderedGroups

  def add_unordered_group(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @unordered_groups << gfa_line
  end
  protected :add_unordered_group

  # Delete an unordered group line from the RGFA object
  # @return [RGFA] self
  # @param unordered_group [RGFA::Line::UnorderedGroup]
  #   unordered group line instance
  def delete_unordered_group(line)
    @unordered_groups.delete(line)
    return self
  end

  # All unordered_group lines of the graph
  # @return [Array<RGFA::Line::UnorderedGroup>]
  def unordered_groups
    @unordered_groups
  end

end
