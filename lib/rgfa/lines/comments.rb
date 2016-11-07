#
# Methods for the RGFA class, which allow to handle comment lines.
#
module RGFA::Lines::Comments

  # All comment lines of the graph
  # @return [Array<RGFA::Line::Comment>]
  def comments
    @records[:"#"]
  end

  # Remove all comments.
  # @return [RGFA] self
  # @api private
  def delete_comments
    @records[:"#"] = []
    return self
  end

end
