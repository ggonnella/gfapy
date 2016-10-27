#
# Methods for the RGFA class, which allow to handle comment lines.
#
module RGFA::Lines::Comments

  def add_comment(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @comments << gfa_line
  end
  protected :add_comment

  # Delete a comment line from the RGFA object
  # @return [RGFA] self
  # @param comment [RGFA::Line::Comment] comment line instance
  def delete_comment(cmt)
    @comments.delete(cmt)
    return self
  end

  # All comment lines of the graph
  # @return [Array<RGFA::Line::Comment>]
  def comments
    @comments
  end

  # Remove all comments.
  # @return [RGFA] self
  # @api private
  def delete_comments
    @comments = []
    return self
  end

end
