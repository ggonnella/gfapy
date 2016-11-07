#
# Methods for the RGFA class, which allow to handle paths in the graph.
#
module RGFA::Lines::Paths

  # All path lines of the graph
  # @return [Array<RGFA::Line::Path>]
  def paths
    @records[:P].values
  end

  # List all names of path lines in the graph
  # @return [Array<Symbol>]
  def path_names
    @records[:P].keys
  end

  # @!macro [new] path
  #   Searches the path with name equal to +pt+.
  #   @param pt [String, RGFA::Line::Path] a path or path name
  #   @return [RGFA::Line::Path] if a path is found
  # @return [nil] if no such path exists in the RGFA instance
  #
  def path(pt)
    return pt if pt.kind_of?(RGFA::Line)
    @records[:P][pt.to_sym]
  end

  # @!macro path
  # @raise [RGFA::NotFoundError] if no such path exists in the RGFA instance
  def path!(pt)
    pt = path(pt)
    raise RGFA::NotFoundError, "No path has name #{pt}" if pt.nil?
    pt
  end

  # @return [Array<RGFA::Line::Path>] paths whose +segment_names+ include the
  #   specified segment.
  # @!macro [new] segment_or_name
  #   @param s [RGFA::Line::SegmentGFA1, Symbol] a segment instance or name
  def paths_with(s)
    segment!(s).all_paths
  end

end
