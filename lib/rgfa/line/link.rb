# A link connects two segments, or a segment to itself.
#
class RGFA::Line::Link < RGFA::Line

  RECORD_TYPE = :L
  REQFIELDS = {:"1.0" => [:from, :from_orient, :to, :to_orient, :overlap],
               :"2.0" => nil}
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
  # @param segment [RGFA::Line::Segment, Symbol] segment name or instance
  # @raise [RGFA::LineMissingError]
  #   if segment is not involved in the link
  # @return [Symbol] the name of the other segment of the link
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

  # @return [RGFA::OrientedSegment] the oriented segment represented by the
  #   from/from_orient fields
  def oriented_from
    [from, from_orient].to_oriented_segment
  end

  # @return [RGFA::OrientedSegment] the oriented segment represented by the
  #   to/to_orient fields
  def oriented_to
    [to, to_orient].to_oriented_segment
  end

  # @return [RGFA::SegmentEnd] the segment end represented by the
  #   from/from_orient fields
  def from_end
    [from, from_orient == :+ ? :E : :B].to_segment_end
  end

  # @return [RGFA::SegmentEnd] the segment end represented by the
  #   to/to_orient fields
  def to_end
    [to, to_orient == :+ ? :B : :E].to_segment_end
  end

  # Signature of the segment ends, for debugging
  # @api private
  def segment_ends_s
    [from_end.to_s, to_end.to_s].join("---")
  end

  # @param segment_end [RGFA::SegmentEnd] one of the two segment ends
  #   of the link
  # @return [RGFA::SegmentEnd] the other segment end
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
  # @return [Symbol]
  def from_name
    from.to_sym
  end

  # The to segment name, in both cases where to is a segment name (Symbol)
  # or a segment (RGFA::Line::Segment)
  # @return [Symbol]
  def to_name
    to.to_sym
  end

  # Returns true if the link is canonical, false otherwise
  #
  # == Definition of canonical link
  #
  # A link if canonical if:
  # - from != to and from < to (lexicographically); or
  # - from == to and at least one of from_orient or to_orient is +
  #
  # === Details
  #
  # In the special case in which from == to (== s) we have the
  # following equivalences:
  #
  #   s + s + == s - s -
  #   s - s - == s + s + (same as previous case)
  #   s + s - == s + s - (equivalent to itself)
  #   s - s + == s - s + (equivalent to itself)
  #
  # Considering the values on the left, the first one can be taken as
  # canonical, the second not, because it can be transformed in the first
  # one; the other two values are canonical, as they are only equivalent
  # to themselves.
  #
  # @return [Boolean]
  #
  def canonical?
    if from_name < to_name
      return true
    elsif from_name > to_name
      return false
    else
      return [from_orient, to_orient].include?(:+)
    end
  end

  # Returns the unchanged link if the link is canonical,
  # otherwise complements the link and returns it.
  #
  # @note The path references are not corrected by this method; therefore
  #   the method shall be used before the link is embedded in a graph.
  #
  # @return [RGFA::Line::Link] self
  def canonicize!
    complement! if !canonical?
  end

  # Creates the equivalent link with from/to inverted.
  #
  # The CIGAR operations (order/type) are inverted as well.
  # Optional fields are left unchanged.
  #
  # @note The path references are not copied to the complement link.
  #
  # @note This method shall be overridden if custom optional fields
  #   are defined, which have a ``complementation'' operation which determines
  #   their value in the equivalent complement link.
  #
  # @return [RGFA::Line::Link] the inverted link.
  def complement
    l = self.clone
    l.from = to
    l.from_orient = (to_orient == :+ ? :- : :+)
    l.to = from
    l.to_orient = (from_orient == :+ ? :- : :+)
    l.overlap = complement_overlap
    l
  end

  # Complements the link inplace, i.e. sets:
  #   from = to
  #   from_orient = other_orient(to_orient)
  #   to = from
  #   to_orient = other_orient(from_orient)
  #   overlap = complement_overlap.
  #
  # The optional fields are left unchanged.
  #
  # @note The path references are not complemented by this method; therefore
  #   the method shall be used before the link is embedded in a graph.
  #
  # @note This method shall be overridden if custom optional fields
  #   are defined, which have a ``complementation'' operation which determines
  #   their value in the complement link.
  #
  # @return [RGFA::Line::Link] self
  def complement!
    tmp = self.from
    self.from = self.to
    self.to = tmp
    tmp = self.from_orient
    self.from_orient = (self.to_orient == :+) ? :- : :+
    self.to_orient = (tmp == :+) ? :- : :+
    self.overlap = self.complement_overlap
    return self
  end

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

  # Compute the overlap when the strand of both sequences is inverted.
  #
  # @return [RGFA::CIGAR, RGFA::Placeholder]
  def complement_overlap
    self.overlap.to_alignment.complement
  end

  #
  # Compares two links and determine their equivalence.
  # Thereby, optional fields are not considered.
  #
  # @note Inverting the strand of both links and reversing
  #   the CIGAR operations (order/type), one obtains an
  #   equivalent complement link.
  #
  # @param other [RGFA::Line::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #==
  # @see #same?
  # @see #complement?
  def eql?(other)
    same?(other) or complement?(other)
  end

  # Compares the optional fields of two links.
  #
  # @note This method shall be overridden if custom optional fields
  #   are defined, which have a ``complementation'' operation which determines
  #   their value in the equivalent but complement link.
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
  # @see #complement?
  # @see #==
  def same?(other)
    (from_end == other.from_end and
      to_end == other.to_end and
      overlap == other.overlap)
  end

  # Compares the link to the complement of another link
  # and determine their equivalence.
  # Thereby, optional fields are not considered.
  #
  # @param other [RGFA::Line::Link] the other link
  # @return [Boolean] are self and the complement of other equivalent?
  # @see #eql?
  # @see #same?
  # @see #==
  def complement?(other)
    (from_end == other.to_end and
      to_end == other.from_end and
      overlap == other.complement_overlap)
  end

  # Computes an hash for including a link in an Hash tables,
  # so that the hash of a link and its complement is the same.
  # Thereby, optional fields are not considered.
  # @see #eql?
  def hash
    from_end.hash + to_end.hash + overlap.hash + complement_overlap.to_s.hash
  end

  # Compares a link and optionally the complement link,
  # with two oriented_segments and optionally an overlap.
  # @param [RGFA::OrientedSegment] other_oriented_from
  # @param [RGFA::OrientedSegment] other_oriented_to
  # @param equivalent [Boolean] shall the complement link also be considered?
  # @param [RGFA::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the link or, if +equivalent+,
  #   the complement link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible?(other_oriented_from, other_oriented_to, other_overlap = [],
                  equivalent = true)
    other_overlap = other_overlap.to_alignment
    is_direct = compatible_direct?(other_oriented_from, other_oriented_to,
                                   other_overlap)
    if is_direct
      return true
    elsif equivalent
      return compatible_complement?(other_oriented_from, other_oriented_to,
                          other_overlap)
    else
      return false
    end
  end

  # Compares a link with two oriented segments and optionally an overlap.
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

  # Compares the complement link with two oriented segments and optionally an
  # overlap.
  # @param [RGFA::OrientedSegment] other_oriented_from
  # @param [RGFA::OrientedSegment] other_oriented_to
  # @param [RGFA::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the complement link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible_complement?(other_oriented_from, other_oriented_to,
                          other_overlap = [])
    (oriented_to == other_oriented_from.invert_orient and
     oriented_from == other_oriented_to.invert_orient) and
     (overlap.empty? or other_overlap.empty? or (overlap == other_overlap))
  end

end
