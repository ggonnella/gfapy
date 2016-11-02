module RGFA::Line::Link::References

  # Paths for which the link is required.
  #
  # The return value is an empty array
  # if the link is not embedded in a graph.
  #
  # Otherwise, an array of tuples path/boolean is returned.
  # The boolean value tells
  # if the link is used (true) or its complement (false)
  # in the path.
  # @return [Array<Array<(RGFA::Line::Path, Boolean)>>]
  def paths
    @paths ||= []
    @paths
  end

end
