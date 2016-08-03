require_relative "error"

#
# Methods for the RGFA class, which allow to handle containments in the graph.
#
module RGFA::Containments

  def add_containment(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @containments << gfa_line
    [:from, :to].each do |dir|
      segment_name = gfa_line.send(dir)
      orient = gfa_line.send(:"#{dir}_orient")
      if !@segments.has_key?(segment_name)
        raise RGFA::LineMissingError if @segments_first_order
        @segments[segment_name] =
          RGFA::Line::Segment.new({:name => segment_name},
                                  virtual: true)
      end
      s = @segments[segment_name]
      s.containments[dir][orient] << gfa_line
      gfa_line.send(:"#{dir}=", s)
    end
  end

  # Delete a containment
  #
  # @param c [RGFA::Line::Containment] containment instance
  # @return [RGFA] self
  def delete_containment(c)
    @containments.delete(c)
    segment(c.from).containments[:from][c.from_orient].delete(c)
    segment(c.to).containments[:to][c.to_orient].delete(c)
  end

  # All containments of the graph
  # @return [Array<RGFA::Line::Containment>]
  def containments
    @containments
  end

  def each_containment(&block)
    @containments.each(&block)
  end

  # Find containment lines whose +from+ segment name is +segment_name+
  # @!macro segment_or_name
  # @return [Array<RGFA::Line::Containment>]
  def contained_in(s)
    s = segment!(s)
    s.containments[:from][:+] + s.containments[:from][:-]
  end

  # Find containment lines whose +to+ segment name is +segment_name+
  # @return [Array<RGFA::Line::Containment>]
  # @!macro segment_or_name
  def containing(s)
    s = segment!(s)
    s.containments[:to][:+] + s.containments[:to][:-]
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
    contained_in(container).select {|l| l.to.to_sym == contained.to_sym }
  end

  # Searches a containment of +contained+ in +container+.
  # Returns the first containment found or nil if none found.
  #
  # @return [RGFA::Line::Containment, nil]
  # @!macro container_contained
  def containment(container, contained)
    contained_in(container).each do |l|
      if l.to.to_sym == contained.to_sym
        return l
      end
    end
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

end
