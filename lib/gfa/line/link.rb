require_relative "../segment_references.rb"

class GFA::Line::Link < GFA::Line

  # @note The field names are derived from the GFA specification at:
  #   https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#link-line
  #   and were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type, /L/],
     [:from,        /[!-)+-<>-~][!-~]*/], # name of segment
     [:from_orient, /\+|-/],              # orientation of From segment
     [:to,          /[!-)+-<>-~][!-~]*/], # name of segment
     [:to_orient,   /\+|-/],              # orientation of To segment
     [:overlap,     /\*|([0-9]+[MIDNSHPX=])+/] # CIGAR string describing overlap
    ]

  FieldCast =
    { :overlap => lambda {|e| e.cigar_operations} }

  OptfieldTypes = {
     "MQ" => "i", # Mapping quality
     "NM" => "i", # # mismatches/gaps
     "RC" => "i", # Read count
     "FC" => "i", # Fragment count
     "KC" => "i"  # k-mer count
    }

  # @param [Array<String>] fields
  # @param [boolean] validate <it>(default: +true+>)</it>
  # @return [GFA::Line::Link]
  def initialize(fields, validate: true)
    super(fields,
          GFA::Line::Link::FieldRegexp,
          GFA::Line::Link::OptfieldTypes,
          GFA::Line::Link::FieldCast,
          validate: validate)
  end

  include GFA::SegmentReferences

  # Compares two links and determine their equivalence.
  # Thereby, optional fields are not considered.
  #
  # Note that inverting the strand of both links and reversing
  # the CIGAR operations (order/type), one obtains an equivalent
  # link.
  #
  # @return [boolean] are the links equivalent to each other.
  def ==(other)
    (from_end == other.from_end and
      to_end == other.to_end and
      overlap(false) == other.overlap(false)) or
    (from_end == other.to_end and
      to_end == other.from_end and
      overlap == other.reverse_overlap)
  end

  # @see ==
  def eql?(other)
    self == other
  end

  # Computes an hash for including a link in an Hash tables,
  # so that the hash of a link and its reverse is the same.
  # Thereby, optional fields are not considered.
  def hash
    from_end.hash + to_end.hash +
      overlap(false).hash + reverse_overlap(false).hash
  end

  # Creates a link with both strands of the sequences inverted.
  # The CIGAR operations (order/type) are inverted as well.
  # Optional fields are left unchanged.
  #
  # @return[GFA::Line::Link] the inverted link.
  def reverse
    l = self.clone
    l.from = to
    l.from_orient = (to_orient == "+" ? "-" : "+")
    l.to = from
    l.to_orient = (from_orient == "+" ? "-" : "+")
    l.overlap = reverse_overlap(false)
    l
  end

  # Compute the overlap when the strand of both sequences is inverted.
  #
  # @return[String] if cast is false
  # @return[Array<[Integer,M|I|D|N|S|H|P|X|=]>] if cast is true
  def reverse_overlap(cast=true)
    overlap(false).send((cast ? :reverse_cigar_operations : :reverse_cigar))
  end

  # @return[Array<String,:E|:B>] the segment end represented by the
  #   from/from_orient fields
  def from_end
    [from, from_orient == "+" ? :E : :B]
  end

  # @return[Array<String,:E|:B>] the segment end represented by the
  #   to/to_orient fields
  def to_end
    [to, to_orient == "+" ? :B : :E]
  end

  # @param[Array<String,:E|:B>] segment_end one of the two segment ends
  #   of the link
  # @return[Array<String,:E|:B>] the other segment end
  #
  # @raise [ArgumentError] if segment_end is not a valid segment end
  #   representation
  # @raise [RuntimeError] if segment_end is not a segment end of the link
  def other_end(segment_end)
    if segment_end.size != 2 and ![:B, :E].include?(segment_end[1])
      raise ArgumentError, "This is not a segment end #{segment_end.inspect}"
    end
    if (from_end == segment_end)
      return to_end
    elsif (to_end == segment_end)
      return from_end
    else
      raise "Segment end '#{segment_end.inspect}' not found"
    end
  end

end
