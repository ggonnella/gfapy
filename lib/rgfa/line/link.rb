require_relative "../segment_references.rb"

# A link line of a RGFA file
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

  include RGFA::SegmentReferences

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
  def eql?(other)
    same?(other) or reverse?(other)
  end

  # Computes an hash for including a link in an Hash tables,
  # so that the hash of a link and its reverse is the same.
  # Thereby, optional fields are not considered.
  # @see #eql?
  def hash
    from_end.hash + to_end.hash +
      overlap(false).hash + reverse_overlap(false).hash
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
      optional_fieldnames.each do |fn|
        self.send(fn) == other.send(fn)
      end
  end

  # Creates a link with both strands of the sequences inverted.
  # The CIGAR operations (order/type) are inverted as well.
  # Optional fields are left unchanged.
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
    l.overlap = reverse_overlap(false)
    l
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
  def ==(other)
    eql?(other) and eql_optional?(other)
  end

  # Compute the overlap when the strand of both sequences is inverted.
  #
  # @param cast [Boolean] cast value?
  # @return [String] if cast is false
  # @return [Array<RGFA::CigarOperation>] if cast is true
  def reverse_overlap(cast=true)
    get_string(:overlap).send((cast ? :reverse_cigar_operations :
                                      :reverse_cigar))
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

  private

  def same?(other)
    (from_end == other.from_end and
      to_end == other.to_end and
      overlap(false) == other.overlap(false))
  end

  def reverse?(other)
    (from_end == other.to_end and
      to_end == other.from_end and
      overlap == other.reverse_overlap)
  end

end
