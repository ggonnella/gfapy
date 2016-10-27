#
# Methods for the RGFA class, which allow to handle paths in the graph.
#
module RGFA::Lines::Paths

  def add_path(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    if @segments.has_key?(gfa_line.path_name)
      raise RGFA::NotUniqueError,
        "Error when adding line: #{gfa_line}\n"+
        "a segment already exists with the name: #{gfa_line.path_name}\n"+
        "Segment: #{@segments[gfa_line.path_name]}"
    elsif @paths.has_key?(gfa_line.path_name)
      raise RGFA::NotUniqueError,
        "Error when adding line: #{gfa_line}\n"+
        "a path already exists with the name: #{gfa_line.path_name}\n"+
        "Path: #{@paths[gfa_line.path_name]}"
    else
      @paths[gfa_line.path_name] = gfa_line
      gfa_line.required_links.each do |from,to,cigar|
        l = nil
        if segment(from.segment) and segment(to.segment)
          l = link_from_to(from, to, cigar)
        end
        if l.nil?
          v = RGFA::Line::Link.new({:from => from.segment,
                                    :from_orient => from.orient,
                                    :to => to.segment,
                                    :to_orient => to.orient,
                                    :overlap => cigar},
                                   virtual: true,
                                   version: :"1.0")
          if @segments_first_order
            raise RGFA::NotFoundError, "Path: #{gfa_line}\n"+
              "requires a non-existing link:\n"+
              "#{v}"
          end
          add_link(v)
          l = v
        end
        direct = l.compatible_direct?(from, to, cigar)
        gfa_line.links << [l, direct]
        l.paths << [gfa_line, direct]
      end
      gfa_line.segment_names.each do |sn_with_o|
        sn_with_o[0] = segment(sn_with_o[0])
        sn_with_o[0].paths[sn_with_o[1]] << gfa_line
      end
    end
  end
  protected :add_path

  # Delete a path from the RGFA graph
  # @return [RGFA] self
  # @param pt [String, RGFA::Line::Path] path name or instance
  def delete_path(pt)
    pt = path!(pt)
    pt.segment_names.each {|sn, o| segment!(sn).paths[o].delete(pt)}
    pt.links.each {|l, dir| l.paths.delete([pt, dir])}
    @paths.delete(pt.path_name)
    return self
  end

  # All path lines of the graph
  # @return [Array<RGFA::Line::Path>]
  def paths
    @paths.values
  end

  # @!macro [new] path
  #   Searches the path with name equal to +pt+.
  #   @param pt [String, RGFA::Line::Path] a path or path name
  #   @return [RGFA::Line::Path] if a path is found
  # @return [nil] if no such path exists in the RGFA instance
  #
  def path(pt)
    return pt if pt.kind_of?(RGFA::Line)
    @paths[pt.to_sym]
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
  #   @param s [RGFA::Line::Segment, Symbol] a segment instance or name
  def paths_with(s)
    segment!(s).all_paths
  end

end
