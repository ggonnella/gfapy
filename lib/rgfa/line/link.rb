# A link connects two segments, or a segment to itself.
#
class RGFA::Line::Link < RGFA::Line

  RECORD_TYPE = :L
  REQFIELDS = [:from, :from_orient, :to, :to_orient, :overlap]
  PREDEFINED_OPTFIELDS = [:MQ, :NM, :RC, :FC, :KC]
  DATATYPE = {
     :from => :lbl,
     :from_orient => :orn,
     :to => :lbl,
     :to_orient => :orn,
     :overlap => :cig,
     :MQ => :i,
     :NM => :i,
     :RC => :i,
     :FC => :i,
     :KC => :i,
  }

  define_field_methods!

  # The other segment of a link
  # @param segment [String, RGFA::Line::Segment] segment name or instance
  # @raise [RGFA::LineMissingError]
  #   if segment is not involved in the link
  # @return [String] the name of the other segment of the link
  #   if circular, then +segment+
  def other(segment)
    segment_name =
      (segment.kind_of?(RGFA::Line::Segment) ? segment.name : segment.to_sym)
    if segment_name == from.to_sym
      to
    elsif segment_name == to.to_sym
      from
    else
      raise RGFA::LineMissingError,
        "Link #{self} does not involve segment #{segment_name}"
    end
  end

  # @return [Boolean] is the from and to segments are equal
  def circular?
    from.to_sym == to.to_sym
  end

  # @return [Boolean] is the from and to segments are equal
  def circular_same_end?
    from_end == to_end
  end

  # @return[RGFA::OrientedSegment] the oriented segment represented by the
  #   from/from_orient fields
  def oriented_from
    [from, from_orient].to_oriented_segment
  end

  # @return[RGFA::OrientedSegment] the oriented segment represented by the
  #   to/to_orient fields
  def oriented_to
    [to, to_orient].to_oriented_segment
  end

  # @return[RGFA::SegmentEnd] the segment end represented by the
  #   from/from_orient fields
  def from_end
    [from, from_orient == :+ ? :E : :B].to_segment_end
  end

  # @return[RGFA::SegmentEnd] the segment end represented by the
  #   to/to_orient fields
  def to_end
    [to, to_orient == :+ ? :B : :E].to_segment_end
  end

  # for debugging
  def segment_ends_s
    [from_end.to_s, to_end.to_s].join("---")
  end

  # @param[RGFA::SegmentEnd] segment_end one of the two segment ends
  #   of the link
  # @return[RGFA::SegmentEnd] the other segment end
  #
  # @raise [ArgumentError] if segment_end is not a valid segment end
  #   representation
  # @raise [RuntimeError] if segment_end is not a segment end of the link
  def other_end(segment_end)
    segment_end = segment_end.to_segment_end
    if (from_end == segment_end)
      return to_end
    elsif (to_end == segment_end)
      return from_end
    else
      raise "Segment end '#{segment_end.inspect}' not found\n"+
            "(from=#{from_end.inspect};to=#{to_end.inspect})"
    end
  end

  # The from segment name, in both cases where from is a segment name (Symbol)
  # or a segment (RGFA::Line::Segment)
  def from_name
    from.to_sym
  end

  # The to segment name, in both cases where to is a segment name (Symbol)
  # or a segment (RGFA::Line::Segment)
  def to_name
    to.to_sym
  end

  # Returns true if the link is normal, false otherwise
  #
  # <b> Definition of normal link </b>
  #
  # Each link has an equivalent reverse link. Consider a link of A to B
  # with a overlap 1M1I2M:
  #
  # from+ to to+ (1M1I2M) == to- to from- (2M1D1M)
  # from- to to- (1M1I2M) == to+ to from+ (2M1D1M)
  # from+ to to- (1M1I2M) == to+ to from- (2M1D1M)
  # from- to to+ (1M1I2M) == to- to from+ (2M1D1M)
  #
  # Consider also the special case, where from == to and the overlap is not
  # specified, or equal to its reverse:
  #
  # from+ to from+ (*) == from- to from- (*) # left has a +; right has no +
  # from- to from- (*) == from+ to from+ (*) # left has no +; right has a +
  # from+ to from- (*) == from+ to from- (*) # left == right
  # from- to from+ (*) == from- to from+ (*) # left == right
  #
  # Thus we define a link as normal if:
  # - from < to (lexicographical comparison of segments)
  # - from == to and overlap.to_s < reverse_overlap.to_s
  # - from == to, overlap == reverse_overlap and at least one orientation is +
  #
  # @return [Boolean]
  #
  def normal?
    if from_name < to_name
      return true
    elsif from_name > to_name
      return false
    else
      overlap_s = overlap.to_s
      reverse_overlap_s = reverse_overlap.to_s
      if overlap_s < reverse_overlap_s
        return true
      elsif overlap_s > reverse_overlap_s
        return false
      else
        return [from_orient, to_orient].include?(:+)
      end
    end
  end

  # Returns the unchanged link if the link is normal,
  # otherwise reverses the link and returns it.
  #
  # @note The path references are not corrected by this method; therefore
  #   the method shall be used before the link is embedded in a graph.
  #
  # @return [RGFA::Line::Link] self
  def normalize!
    reverse! if !normal?
  end

  # Creates a link with both strands of the sequences inverted.
  # The CIGAR operations (order/type) are inverted as well.
  # Optional fields are left unchanged.
  #
  # @note The path references are not copied to the reverse link.
  #
  # @note This method shall be overridden if custom optional fields
  #   are defined, which have a ``reverse'' operation which determines
  #   their value in the equivalent but reverse link.
  #
  # @return[RGFA::Line::Link] the inverted link.
  def reverse
    l = self.clone
    l.from = to
    l.from_orient = (to_orient == :+ ? :- : :+)
    l.to = from
    l.to_orient = (from_orient == :+ ? :- : :+)
    l.overlap = reverse_overlap
    l
  end

  # Reverses the link inplace, i.e. sets:
  #   from = to
  #   from_orient = other_orient(to_orient)
  #   to = from
  #   to_orient = other_orient(from_orient)
  #   overlap = reverse_overlap.
  #
  # The optional fields are left unchanged.
  #
  # @note The path references are not reversed by this method; therefore
  #   the method shall be used before the link is embedded in a graph.
  #
  # @note This method shall be overridden if custom optional fields
  #   are defined, which have a ``reverse'' operation which determines
  #   their value in the equivalent but reverse link.
  #
  # @return [RGFA::Line::Link] self
  def reverse!
    tmp = self.from
    self.from = self.to
    self.to = tmp
    tmp = self.from_orient
    self.from_orient = (self.to_orient == :+) ? :- : :+
    self.to_orient = (tmp == :+) ? :- : :+
    self.overlap = self.reverse_overlap
    return self
  end

  # An array of paths for which a link is required. The array is empty
  # is the link is not embedded in a graph. The boolean value says
  # if the link is used in direct or reverse direction in the path.
  # @return [Array<[GFA::Line::Path, Boolean]>]
  def paths
    @paths ||= []
    @paths
  end

  # Compute the overlap when the strand of both sequences is inverted.
  #
  # @return [RGFA::CIGAR]
  def reverse_overlap
    self.overlap.reverse
  end

  #
  # Compares two links and determine their equivalence.
  # Thereby, optional fields are not considered.
  #
  # @note Inverting the strand of both links and reversing
  #   the CIGAR operations (order/type), one obtains a
  #   reverse but equivalent link.
  #
  # @param other [RGFA::Line::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #==
  # @see #same?
  # @see #reverse?
  def eql?(other)
    same?(other) or reverse?(other)
  end

  # Compares the optional fields of two links.
  #
  # @note This method shall be overridden if custom optional fields
  #   are defined, which have a ``reverse'' operation which determines
  #   their value in the equivalent but reverse link.
  #
  # @param other [RGFA::Line::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #==
  def eql_optional?(other)
    (self.optional_fieldnames.sort == other.optional_fieldnames.sort) and
      optional_fieldnames.each {|fn| self.get(fn) == other.get(fn)}
  end

  # Compares two links and determine their equivalence.
  # Optional fields must have the same content.
  #
  # @note Inverting the strand of both links and reversing
  #   the CIGAR operations (order/type), one obtains an equivalent
  #   link.
  #
  # @param other [RGFA::Line::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #eql?
  # @see #eql_optional?
  #def ==(other)
  #  eql?(other) and eql_optional?(other)
  #end

  # Compares two links and determine their equivalence.
  # Thereby, optional fields are not considered.
  #
  # @param other [RGFA::Line::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #eql?
  # @see #reverse?
  # @see #==
  def same?(other)
    (from_end == other.from_end and
      to_end == other.to_end and
      overlap == other.overlap)
  end

  # Compares the reverse of the link to another link
  # and determine their equivalence.
  # Thereby, optional fields are not considered.
  #
  # @param other [RGFA::Line::Link] the other link
  # @return [Boolean] are the reverse of self and other equivalent?
  # @see #eql?
  # @see #same?
  # @see #==
  def reverse?(other)
    (from_end == other.to_end and
      to_end == other.from_end and
      overlap == other.reverse_overlap)
  end

  # Computes an hash for including a link in an Hash tables,
  # so that the hash of a link and its reverse is the same.
  # Thereby, optional fields are not considered.
  # @see #eql?
  def hash
    overlap_s = overlap.to_s
    reverse_overlap_s = reverse_overlap.to_s
    if reverse_overlap_s < overlap_s
      overlap_s = reverse_overlap_s
    end
    from_end_s = from_end.hash
    to_end_s = to_end.hash
    if from_end_s < to_end_s
      from_end_s + to_end_s + overlap_s
    else
      to_end_s + from_end_s + overlap_s
    end
  end

  # Compares a link and optionally the reverse link,
  #   with two oriented_segments and optionally an overlap.
  # @param [RGFA::OrientedSegment] other_oriented_from
  # @param [RGFA::OrientedSegment] other_oriented_to
  # @param equivalent [Boolean] shall the reverse link also be considered?
  # @param [RGFA::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the link or, if +equivalent+,
  #   the reverse link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible?(other_oriented_from, other_oriented_to, other_overlap = [],
                  equivalent = true)
    other_overlap = other_overlap.to_cigar
    is_direct = compatible_direct?(other_oriented_from, other_oriented_to,
                                   other_overlap)
    if is_direct
      return true
    elsif equivalent
      return compatible_reverse?(other_oriented_from, other_oriented_to,
                          other_overlap)
    else
      return false
    end
  end

  # Compares a link with two oriented_segments and optionally an overlap.
  # @param [RGFA::OrientedSegment] other_oriented_from
  # @param [RGFA::OrientedSegment] other_oriented_to
  # @param [RGFA::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible_direct?(other_oriented_from, other_oriented_to,
                         other_overlap = [])
    (oriented_from == other_oriented_from and
     oriented_to == other_oriented_to) and
     (overlap.empty? or other_overlap.empty? or (overlap == other_overlap))
  end

  # Compares the reverse link with two oriented_segments and optionally an
  # overlap.
  # @param [RGFA::OrientedSegment] other_oriented_from
  # @param [RGFA::OrientedSegment] other_oriented_to
  # @param [RGFA::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the reverse link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible_reverse?(other_oriented_from, other_oriented_to,
                          other_overlap = [])
    (oriented_to == other_oriented_from.invert_orient and
     oriented_from == other_oriented_to.invert_orient) and
     (overlap.empty? or other_overlap.empty? or (overlap == other_overlap))
  end

end
