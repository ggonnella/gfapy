#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::Lines::Finders

  # @!macro [new] segment
  #   Searches the segment with name equal to +segment_name+.
  #   @param s
  #     [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #     segment name or instance
  #   @return [RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #     if a segment is found
  # @return [nil] if no such segment exists in the RGFA instance
  #
  def segment(s)
    return s if s.kind_of?(RGFA::Line)
    @records[:S][s.to_sym]
  end

  # @!macro segment
  # @raise [RGFA::NotFoundError] if no such segment exists
  def segment!(s)
    seg = segment(s)
    if seg.nil?
      raise RGFA::NotFoundError, "No segment has name #{s}"+
             "#{segment_names.size < 10 ?
               "\nSegment names: "+segment_names.inspect : ''}"
    end
    seg
  end

  # Record types whose references are stored in the RGFA instance
  # in hashes, where the key is a name field
  RECORDS_WITH_NAME = [:E, :S, :P, :U, :G, :O, nil]

  # Find the line with the given l
  # @param l [Symbol, RGFA::Line, RGFA::Placeholder] the line to search
  # @return [RGFA::Line, nil] if +l+ is a line, then it is returned;
  #   otherwise, the line is search with name +l+; if such a line does
  #   not exist +nil+ is returned
  def line(l)
    return nil if l.placeholder?
    return l if l.kind_of?(RGFA::Line)
    RECORDS_WITH_NAME.each do |rt|
      return nil if !@records[rt]
      found = @records[rt][l.to_sym]
      return found if !found.nil?
    end
    return nil
  end

  # Find the line with the given name, and raise an exception if it does not
  # exist
  # @param l [Symbol, RGFA::Line, RGFA::Placeholder] the line to search
  # @raise [RGFA::ValueError] if +l+ is a placeholder
  # @raise [RGFA::NotFoundError] if no line with the given name +l+ exists
  # @return [RGFA::Line, nil] if +l+ is a line, then it is returned;
  #   otherwise, return the line with name +l+
  def line!(l)
    gfa_line = line(l)
    if gfa_line.nil?
      if l.placeholder?
        raise RGFA::ValueError,
          "Cannot search a line with l '*'"
      else
        raise RGFA::NotFoundError,
          "No line found with ID '#{l}'"
      end
    end
    return gfa_line
  end

  # Returns all the fragments where the ```external``` ID is the specified ID.
  # @return [Array<RGFA::Line::Fragment>]
  def fragments_for_external(id)
    @records[:F].fetch(id.to_sym, [])
  end

  # @api private
  module API_PRIVATE

    # Search a possible duplicate of the gfa_line.
    def search_duplicate(gfa_line)
      case gfa_line.record_type
      when :L
        return search_link(gfa_line.oriented_from,
                           gfa_line.oriented_to, gfa_line.alignment)
      when *RECORDS_WITH_NAME
        return line(gfa_line.name)
      else
        return nil
      end
    end

    # Search the link from a segment S1 in a given orientation
    # to another segment S2 in a given, or the equivalent
    # link from S2 to S1 with inverted orientations.
    #
    # @param [RGFA::OrientedLine] oriented_segment1 a segment with orientation
    # @param [RGFA::OrientedLine] oriented_segment2 a segment with orientation
    # @param [RGFA::Alignment::CIGAR] cigar
    # @return [RGFA::Line::Edge::Link] the first link found
    # @return [nil] if no link is found.
    def search_link(oriented_segment1, oriented_segment2, cigar)
      s = segment(oriented_segment1.line)
      return nil if s.nil?
      s.dovetails.each do |l|
        return l if l.kind_of?(RGFA::Line::Edge::Link) and
          l.compatible?(oriented_segment1, oriented_segment2, cigar, true)
      end
      return nil
    end

  end
  include API_PRIVATE

end
