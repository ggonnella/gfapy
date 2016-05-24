#
# Methods for the GFA class, which allow to retrieve specific lines.
#
module GFA::LineGetters

  GFA::Line::RecordTypes.each do |rt, klass|
    klass =~ /GFA::Line::(.*)/
    define_method(:"#{$1.downcase}s") { lines(rt) }
    define_method(:"each_#{$1.downcase}") { |&block| each(rt, &block) }
  end

  # Searches the segment with name equal to +segment_name+.
  #
  # *Returns*:
  #   - +nil+ if no such segment exists in the gfa
  #   - a GFA::Line::Segment instance otherwise
  def segment(segment_name)
    i = @segment_names.index(segment_name)
    i.nil? ? nil : @lines["S"][i]
  end

  # Calls +segment+ and raises a +RuntimeError+ if no segment was found.
  def segment!(segment_name)
    s = segment(segment_name)
    raise "No segment has name #{segment_name}" if s.nil?
    s
  end

  # Searches the path with name equal to +path_name+.
  #
  # *Returns*:
  #   - +nil+ if no such path exists in the gfa
  #   - a GFA::Line::Path instance otherwise
  def path(path_name)
    i = @path_names.index(path_name)
    i.nil? ? nil : @lines["P"][i]
  end

  # Calls +path+ and raises a +RuntimeError+ if no path was found.
  def path!(path_name)
    pt = path(path_name)
    raise "No path has name #{path_name}" if pt.nil?
    pt
  end

  # Find path lines whose +segment_names+ include segment +segment_name+
  def paths_with(segment_name)
    @paths_with.fetch(segment_name,[]).map{|i|@lines["P"][i]}
  end

  # Find containment lines whose +from+ segment name is +segment_name+
  def contained_in(segment_name)
    connection_lines("C", :from, segment_name)
  end

  # Find containment lines whose +to+ segment name is +segment_name+
  def containing(segment_name)
    connection_lines("C", :to, segment_name)
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
    raise "No containment was found" if c.nil?
    c
  end

  # Find links of the specified end of segment
  #
  # *Returns*
  #   - An array of GFA::Line::Link containing:
  #     - if end_type == :E
  #       links from sn with from_orient +
  #       links to   sn with to_orient   -
  #     - if end_type == :B
  #       links to   sn with to_orient   +
  #       links from sn with from_orient -
  #     - if end_type == nil
  #       all links of sn
  #
  # *Note*:
  #   - To add or remove links, use +connect()+ or +disconnect()+;
  #     adding or removing links from the returned array will not work
  def links_of(sn, end_type)
    case end_type
    when :E
      o = ["+","-"]
    when :B
      o = ["-","+"]
    when nil
      return links_of(sn, :B) + links_of(sn, :E)
    else
      raise "end_type unknown: #{end_type.inspect}"
    end
    connection_lines("L",:from,sn,o[0]) + connection_lines("L",:to,sn,o[1])
  end

  # Searches all links between the segment +sn1+ end +end_type1+
  # and the segment +sn2+ end +end_type2+
  #
  # The end_types can be set to nil, in which case both ends are searched.
  #
  # Returns a possibly empty array of links.
  def links_between(sn1, end_type1, sn2, end_type2)
    links_of(sn1, end_type1).select do |l|
      l.other(sn1) == sn2 and
        (end_type2.nil? or l.other_end_type(sn1) == end_type2)
    end
  end

  # Searches a link between the segment +sn1+ end +end_type1+
  # and the segment +sn2+ end +end_type2+
  #
  # The end_types can be set to nil, in which case both ends are searched.
  #
  # Returns the first link found or nil if none found.
  def link(sn1, end_type1, sn2, end_type2)
    links_of(sn1, end_type1).each do |l|
      return l if l.other(sn1) == sn2 and
        (end_type2.nil? or l.other_end_type(sn1) == end_type2)
    end
    return nil
  end

  # Calls +link+ and raises a +RuntimeError+ if no link was found.
  def link!(sn1, end_type1, sn2, end_type2)
    l = link(sn1, end_type1, sn2, end_type2)
    raise "No link was found" if l.nil?
    l
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
