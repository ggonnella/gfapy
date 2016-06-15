#
# Methods for the GFA class, which allow to retrieve specific lines.
#
module GFA::LineGetters

  GFA::Line::RecordTypes.each do |rt, klass|
    klass =~ /GFA::Line::(.*)/
    define_method(:"#{$1.downcase}s") { lines(rt) }
    define_method(:"each_#{$1.downcase}") { |&block| each(rt, &block) }
  end

  # @!macro [new] segment
  #   Searches the segment with name equal to +segment_name+.
  #   @param segment_name [String] a segment name
  #   @return [GFA::Line::Segment] if a segment is found
  # @return [nil] if no such segment exists in the GFA instance
  #
  def segment(segment_name)
    i = @segment_names[segment_name.to_sym]
    i.nil? ? nil : @lines["S"][i]
  end

  # @!macro segment
  # @raise [GFA::LineMissingError] if no such segment exists in the GFA instance
  def segment!(segment_name)
    s = segment(segment_name)
    raise GFA::LineMissingError,
      "No segment has name #{segment_name}" if s.nil?
    s
  end

  # @!macro [new] path
  #   Searches the path with name equal to +path_name+.
  #   @param path_name [String] a path name
  #   @return [GFA::Line::Path] if a path is found
  # @return [nil] if no such path exists in the GFA instance
  #
  def path(path_name)
    i = @path_names[path_name.to_sym]
    i.nil? ? nil : @lines["P"][i]
  end

  # @!macro path
  # @raise [GFA::LineMissingError] if no such path exists in the GFA instance
  def path!(path_name)
    pt = path(path_name)
    raise GFA::LineMissingError,
      "No path has name #{path_name}" if pt.nil?
    pt
  end

  # @return [Array<GFA::Line::Path>] paths whose +segment_names+ include the
  #   specified segment.
  # @!macro [new] segment_or_name
  #   @overload $0(segment)
  #     @param segment [GFA::Line::Segment] a segment instance
  #   @overload $0(segment_name)
  #     @param segment_name [String] a segment name
  def paths_with(segment_name)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    @c.lines("P",segment_name)
  end

  # Find containment lines whose +from+ segment name is +segment_name+
  # @!macro segment_or_name
  def contained_in(segment_name)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    @c.lines("C", segment_name, :from)
  end

  # Find containment lines whose +to+ segment name is +segment_name+
  # @!macro segment_or_name
  def containing(segment_name)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    @c.lines("C", segment_name, :to)
  end

  # Searches all containments of +contained+ in +container+.
  #
  # Returns a possibly empty array of containments.
  def containments_between(container, contained)
    contained_in(container).select {|l| l.to == contained }
  end

  # Searches a containment of +contained+ in +container+.
  #
  # Returns the first containment found or nil if none found.
  def containment(container, contained)
    contained_in(container).each {|l| return l if l.to == contained }
    return nil
  end

  # Calls +containment+ and raises a +RuntimeError+ if no containment was found.
  def containment!(container, contained)
    c = containment(container, contained)
    raise GFA::LineMissingError, "No containment was found" if c.nil?
    c
  end

  # Finds links of the specified end of segment.
  #
  # @param [GFA::SegmentEnd] segment_end a segment end
  #
  # @return [Array<GFA::Line::Link>] if segment_end[1] == :E,
  #   links from sn with from_orient + and to sn with to_orient -
  # @return [Array<GFA::Line::Link>] if segment_end[1] == :B,
  #   links to sn with to_orient + and from sn with from_orient -
  #
  # @note to add or remove links, use the appropriate methods;
  #   adding or removing links from the returned array will not work
  def links_of(segment_end)
    segment_end = segment_end.to_segment_end
    o = segment_end.end_type == :E ? ["+","-"] : ["-","+"]
    @c.lines("L",segment_end.segment,:from,o[0]) +
      @c.lines("L",segment_end.segment,:to,o[1])
  end

  # Finds segment ends connected to the specified segment end.
  #
  # @param [GFA::SegmentEnd] segment_end a segment end
  #
  # @return [Array<GFA::SegmentEnd>>] segment ends connected by links
  #   to +segment_end+
  def neighbours(segment_end)
    links_of(segment_end).map {|l| l.other_end(segment_end) }
  end

  # @return [GFA::SegmentEnd] the other end of a segment
  #
  # @param [GFA::SegmentEnd] segment_end a segment end
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
  #   @param segment_end1 [GFA::SegmentEnd] a segment end
  #   @param segment_end2 [GFA::SegmentEnd] a segment end
  # @return [Array<GFA::Line::Link>] (possibly empty)
  def links_between(segment_end1, segment_end2)
    links_of(segment_end1).select do |l|
      l.other_end(segment_end1) == segment_end2
    end
  end

  # @!macro [new] link
  #   Searches a link between +segment_end1+ and +segment_end2+
  #   @!macro two_segment_ends
  #   @return [GFA::Line::Link] the first link found
  # @return [nil] if no link is found.
  def link(segment_end1, segment_end2)
    links_of(segment_end1).each do |l|
      return l if l.other_end(segment_end1) == segment_end2
    end
    return nil
  end

  # @!macro link
  # @raise [GFA::LineMissingError] if no link is found.
  def link!(segment_end1, segment_end2)
    l = link(segment_end1, segment_end2)
    raise GFA::LineMissingError,
      "No link was found: "+
          "#{segment_end1.join(":")} -- "+
          "#{segment_end2.join(":")}" if l.nil?
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
# exist in the GFA
class GFA::LineMissingError < ArgumentError; end
