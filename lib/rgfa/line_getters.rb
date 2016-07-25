require_relative "error"

#
# Methods for the RGFA class, which allow to retrieve specific lines.
#
module RGFA::LineGetters

  # @!method links
  #   All links of the graph
  #   @return [Array<RGFA::Line::Link>]
  # @!method segments
  #   All segments of the graph
  #   @return [Array<RGFA::Line::Segment>]
  # @!method paths
  #   All path lines of the graph
  #   @return [Array<RGFA::Line::Path>]
  # @!method headers
  #   All header lines of the graph
  #   @return [Array<RGFA::Line::Header>]
  # @!method containments
  #   All containments of the graph
  #   @return [Array<RGFA::Line::Containment>]
  # @!method each_link
  #   Iterate over all links of the graph
  #   @yield [RGFA::Line::Link]
  # @!method each_segment
  #   Iterate over all segments of the graph
  #   @yield [RGFA::Line::Segment]
  # @!method each_path
  #   Iterate over all path lines of the graph
  #   @yield [RGFA::Line::Path]
  # @!method each_header
  #   Iterate over all header lines of the graph
  #   @yield [RGFA::Line::Header]
  # @!method each_containment
  #   Iterate over all containments of the graph
  #   @yield [RGFA::Line::Containment]
  RGFA::Line::RECORD_TYPE_LABELS.each do |rt, label|
    define_method(:"#{label}s") { lines(rt) }
    define_method(:"each_#{label}") { |&block| each(rt, &block) }
  end

  # Iterate over all lines of the graph
  # @yield [RGFA::Line]
  def each_line(&block)
    RGFA::Line::RECORD_TYPES.each {|rt| each(rt, &block) }
  end

  # @!macro [new] segment
  #   Searches the segment with name equal to +segment_name+.
  #   @param segment_name [String] a segment name
  #   @return [RGFA::Line::Segment] if a segment is found
  # @return [nil] if no such segment exists in the RGFA instance
  #
  def segment(segment_name)
    i = @segment_names[segment_name.to_sym]
    i.nil? ? nil : @lines[:S][i]
  end

  # @!macro segment
  # @raise [RGFA::LineMissingError] if no such segment exists
  def segment!(segment_name)
    s = segment(segment_name)
    raise RGFA::LineMissingError,
      "No segment has name #{segment_name}" if s.nil?
    s
  end

  # @!macro [new] path
  #   Searches the path with name equal to +path_name+.
  #   @param path_name [String] a path name
  #   @return [RGFA::Line::Path] if a path is found
  # @return [nil] if no such path exists in the RGFA instance
  #
  def path(path_name)
    i = @path_names[path_name.to_sym]
    i.nil? ? nil : @lines[:P][i]
  end

  # @!macro path
  # @raise [RGFA::LineMissingError] if no such path exists in the RGFA instance
  def path!(path_name)
    pt = path(path_name)
    raise RGFA::LineMissingError,
      "No path has name #{path_name}" if pt.nil?
    pt
  end

  # @return [Array<RGFA::Line::Path>] paths whose +segment_names+ include the
  #   specified segment.
  # @!macro [new] segment_or_name
  #   @param segment [RGFA::Line::Segment, String] a segment instance or name
  def paths_with(segment)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment.to_sym
    @c.lines(:P,segment_name)
  end

  # Find containment lines whose +from+ segment name is +segment_name+
  # @!macro segment_or_name
  # @return [Array<RGFA::Line::Containment>]
  def contained_in(segment)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment.to_sym
    @c.lines(:C, segment_name, :from)
  end

  # Find containment lines whose +to+ segment name is +segment_name+
  # @return [Array<RGFA::Line::Containment>]
  # @!macro segment_or_name
  def containing(segment)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment.to_sym
    @c.lines(:C, segment_name, :to)
  end

  # Searches all containments of +contained+ in +container+.
  # Returns a possibly empty array of containments.
  #
  # @return [Array<RGFA::Line::Containment>]
  # @!macro [new] container_contained
  #   @param container [RGFA::Line::Segment, String] a segment instance or name
  #   @param contained [RGFA::Line::Segment, String] a segment instance or name
  #
  def containments_between(container, contained)
    container = container.kind_of?(RGFA::Line) ? container.name
                                               : container.to_sym
    contained = contained.kind_of?(RGFA::Line) ? contained.name
                                               : contained.to_sym
    contained_in(container).select {|l| l.to == contained }
  end

  # Searches a containment of +contained+ in +container+.
  # Returns the first containment found or nil if none found.
  #
  # @return [RGFA::Line::Containment, nil]
  # @!macro container_contained
  def containment(container, contained)
    container = container.kind_of?(RGFA::Line) ? container.name
                                               : container.to_sym
    contained = contained.kind_of?(RGFA::Line) ? contained.name
                                               : contained.to_sym
    contained_in(container).each {|l| return l if l.to == contained }
    return nil
  end

  # Searches a containment of +contained+ in +container+.
  # Raises a +RuntimeError+ if no containment was found.
  #
  # @return [RGFA::Line::Containment]
  # @raise [RGFA::LineMissingError] if no such containment found
  # @!macro container_contained
  def containment!(container, contained)
    c = containment(container, contained)
    raise RGFA::LineMissingError, "No containment was found" if c.nil?
    c
  end

  # Finds links of the specified end of segment.
  #
  # @param [RGFA::SegmentEnd] segment_end a segment end
  #
  # @return [Array<RGFA::Line::Link>] if segment_end[1] == :E,
  #   links from sn with from_orient + and to sn with to_orient -
  # @return [Array<RGFA::Line::Link>] if segment_end[1] == :B,
  #   links to sn with to_orient + and from sn with from_orient -
  #
  # @note to add or remove links, use the appropriate methods;
  #   adding or removing links from the returned array will not work
  def links_of(segment_end)
    segment_end = segment_end.to_segment_end
    o = segment_end.end_type == :E ? [:+,:-] : [:-,:+]
    @c.lines(:L,segment_end.segment,:from,o[0]) +
      @c.lines(:L,segment_end.segment,:to,o[1])
  end

  # Finds segment ends connected to the specified segment end.
  #
  # @param [RGFA::SegmentEnd] segment_end a segment end
  #
  # @return [Array<RGFA::SegmentEnd>>] segment ends connected by links
  #   to +segment_end+
  def neighbours(segment_end)
    links_of(segment_end).map {|l| l.other_end(segment_end) }
  end

  # @return [RGFA::SegmentEnd] the other end of a segment
  #
  # @param [RGFA::SegmentEnd] segment_end a segment end
  def other_segment_end(segment_end)
    segment_end.to_segment_end.other_end
  end

  # @return [Array<String>] list of names of segments connected to +segment+
  #   by links or containments
  def connected_segments(segment)
    (neighbours([segment, :B]).map{|s, e| s} +
      neighbours([segment, :E]).map{|s, e| s} +
        contained_in(segment).map{|c| c.to} +
          containing(segment).map{|c| c.from}).uniq
  end

  # Searches all links between +segment_end1+ and +segment_end2+
  #
  # @!macro [new] two_segment_ends
  #   @param segment_end1 [RGFA::SegmentEnd] a segment end
  #   @param segment_end2 [RGFA::SegmentEnd] a segment end
  # @return [Array<RGFA::Line::Link>] (possibly empty)
  def links_between(segment_end1, segment_end2)
    segment_end1 = segment_end1.to_segment_end
    segment_end2 = segment_end2.to_segment_end
    links_of(segment_end1).select do |l|
      l.other_end(segment_end1) == segment_end2
    end
  end

  # @!macro [new] link
  #   Searches a link between +segment_end1+ and +segment_end2+
  #   @!macro two_segment_ends
  #   @return [RGFA::Line::Link] the first link found
  # @return [nil] if no link is found.
  def link(segment_end1, segment_end2)
    segment_end1 = segment_end1.to_segment_end
    segment_end2 = segment_end2.to_segment_end
    links_of(segment_end1).each do |l|
      return l if l.other_end(segment_end1) == segment_end2
    end
    return nil
  end

  # @!macro link
  # @raise [RGFA::LineMissingError] if no link is found.
  def link!(segment_end1, segment_end2)
    l = link(segment_end1, segment_end2)
    raise RGFA::LineMissingError,
      "No link was found: "+
          "#{segment_end1.join(":")} -- "+
          "#{segment_end2.join(":")}" if l.nil?
    l
  end

  # Find links from the segment in the specified orientation
  # or to the segment in opposite orientation.
  #
  # @param [RGFA::OrientedSegment] oriented_segment a segment with orientation
  # @return [Array<RGFA::Line::Link>]
  # @note to add or remove links, use the appropriate methods;
  #   adding or removing links from the returned array will not work
  def links_from(oriented_segment)
    oriented_segment = oriented_segment.to_oriented_segment
    @c.lines(:L,oriented_segment.segment,
             :from,oriented_segment.orient) +
    @c.lines(:L,oriented_segment.segment,
             :to,oriented_segment.orient_inverted)
  end

  # Find links to the segment in the specified orientation
  # or from the segment in opposite orientation.
  #
  # @param [RGFA::OrientedSegment] oriented_segment a segment with orientation
  # @return [Array<RGFA::Line::Link>]
  # @note to add or remove links, use the appropriate methods;
  #   adding or removing links from the returned array will not work
  def links_to(oriented_segment)
    oriented_segment = oriented_segment.to_oriented_segment
    @c.lines(:L,oriented_segment.segment,
             :to,oriented_segment.orient) +
    @c.lines(:L,oriented_segment.segment,
             :from,oriented_segment.orient_inverted)
  end

  # Search all links from a segment S1 in a given orientation
  # to another segment S2 in a given, or the equivalent
  # links from S2 to S1 with inverted orientations.
  #
  # @param [RGFA::OrientedSegment] oriented_segment1 a segment with orientation
  # @param [RGFA::OrientedSegment] oriented_segment2 a segment with orientation
  # @param [RGFA::CIGAR] cigar shall match if not empty/undef
  # @return [Array<RGFA::Line::Link>]
  # @note to add or remove links, use the appropriate methods;
  #   adding or removing links from the returned array will not work
  def links_from_to(oriented_segment1, oriented_segment2, cigar = [])
    oriented_segment1 = oriented_segment1.to_oriented_segment
    oriented_segment2 = oriented_segment2.to_oriented_segment
    links_from(oriented_segment1).select do |l|
      l.compatible?(oriented_segment1, oriented_segment2, cigar)
    end
  end

  # Search the link from a segment S1 in a given orientation
  # to another segment S2 in a given, or the equivalent
  # link from S2 to S1 with inverted orientations.
  #
  # @param [RGFA::OrientedSegment] oriented_segment1 a segment with orientation
  # @param [RGFA::OrientedSegment] oriented_segment2 a segment with orientation
  # @param [RGFA::CIGAR] cigar shall match if not empty/undef
  # @return [RGFA::Line::Link] the first link found
  # @return [nil] if no link is found.
  def link_from_to(oriented_segment1, oriented_segment2, cigar = [])
    oriented_segment1 = oriented_segment1.to_oriented_segment
    oriented_segment2 = oriented_segment2.to_oriented_segment
    links_from(oriented_segment1).select do |l|
      return l if l.compatible?(oriented_segment1, oriented_segment2, cigar)
    end
    return nil
  end

  # Search the link from a segment S1 in a given orientation
  # to another segment S2 in a given, or the equivalent
  # link from S2 to S1 with inverted orientations.
  #
  # @param [RGFA::OrientedSegment] oriented_segment1 a segment with orientation
  # @param [RGFA::OrientedSegment] oriented_segment2 a segment with orientation
  # @param [RGFA::CIGAR] cigar shall match if not empty/undef
  # @return [RGFA::Line::Link] the first link found
  # @raise [RGFA::LineMissingError] if no link is found.
  def link_from_to!(oriented_segment1, oriented_segment2)
    l = link_from_to!(oriented_segment1, oriented_segment2)
    raise RGFA::LineMissingError,
      "No link was found: "+
          "#{oriented_segment1.join(":")} -> "+
          "#{oriented_segment2.join(":")}" if l.nil?
    l
  end

  # @return [Hash{Symbol:Object}] data contained in the header fields;
  #   the special key :multiple_values contains an array of fields for
  #   which multiple values were defined in multiple lines; in this case
  #   the values are summarized in an array
  def headers_data
    data = {}
    data[:multiple_values] = []
    headers.each do |hline|
      hline.optional_fieldnames.each do |of|
        if data.has_key?(of)
          if !data[:multiple_values].include?(of)
            data[of] = [data[of]]
            data[:multiple_values] << of
          end
          data[of] << hline.send(of)
        else
          data[of] = hline.send(of)
        end
      end
    end
    return data
  end

  # @return [Array<Array{Tagname,Datatype,Value}>] all header fields;
  def headers_array
    data = []
    headers.each do |hline|
      hline.optional_fieldnames.each do |of|
        data << [of, hline.get_datatype(of), hline.send(of)]
      end
    end
    return data
  end

  private

  def each(record_type, &block)
    @lines[record_type].each do |line|
      next if line.nil?
      yield line
    end
  end

  def lines(record_type)
    retval = []
    each(record_type) {|l| retval << l}
    return retval
  end

end

# The error raised by banged line finders if no line respecting the criteria
# exist in the RGFA
class RGFA::LineMissingError < RGFA::Error; end
