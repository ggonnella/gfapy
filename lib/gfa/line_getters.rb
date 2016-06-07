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
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    @c.lines("P",segment_name)
  end

  # Find containment lines whose +from+ segment name is +segment_name+
  def contained_in(segment_name)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    @c.lines("C", segment_name, :from)
  end

  # Find containment lines whose +to+ segment name is +segment_name+
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
    raise "No containment was found" if c.nil?
    c
  end

  # Find links of the specified end of segment
  #
  # *Returns*
  #   - An array of GFA::Line::Link containing:
  #     - if segment_end[1] == :E
  #       links from sn with from_orient +
  #       links to   sn with to_orient   -
  #     - if segment_end[1] == :B
  #       links to   sn with to_orient   +
  #       links from sn with from_orient -
  #
  # *Note*:
  #   - To add or remove links, use +connect()+ or +disconnect()+;
  #     adding or removing links from the returned array will not work
  def links_of(segment_end)
    case segment_end[1]
    when :E
      o = ["+","-"]
    when :B
      o = ["-","+"]
    else
      raise "end_type unknown: #{segment_end[1].inspect}"
    end
    @c.lines("L",segment_end[0],:from,o[0]) +
      @c.lines("L",segment_end[0],:to,o[1])
  end

  def neighbours(segment_end)
    links_of(segment_end).map {|l| l.other_end(segment_end) }
  end

  def other_segment_end(segment_end)
    [segment_end[0], segment_end[1] == :B ? :E : :B]
  end

  def connected_segments(segment_name)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    (neighbours([segment_name, :B]).map{|s, e| s} +
      neighbours([segment_name, :E]).map{|s, e| s} +
        contained_in(segment_name).map{|c| c.to} +
          containing(segment_name).map{|c| c.from}).uniq
  end

  # Searches all links between +segment_end1+ and +segment_end2+
  #
  # Returns a possibly empty array of links.
  def links_between(segment_end1, segment_end2)
    links_of(segment_end1).select do |l|
      l.other_end(segment_end1) == segment_end2
    end
  end

  # Searches a link between +segment_end1+ and +segment_end2+
  #
  # Returns the first link found or nil if none found.
  def link(segment_end1, segment_end2)
    links_of(segment_end1).each do |l|
      return l if l.other_end(segment_end1) == segment_end2
    end
    return nil
  end

  # Calls +link+ and raises a +RuntimeError+ if no link was found.
  def link!(segment_end1, segment_end2)
    l = link(segment_end1, segment_end2)
    raise "No link was found: "+
          "#{segment_end1.join(":")} -- "+
          "#{segment_end2.join(":")}" if l.nil?
    l
  end

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
