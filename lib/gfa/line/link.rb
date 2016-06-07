require_relative "../segment_references.rb"

class GFA::Line::Link < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#link-line
  # note: the field names were made all downcase with _ separating words
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

  def initialize(fields, validate: true)
    super(fields,
          GFA::Line::Link::FieldRegexp,
          GFA::Line::Link::OptfieldTypes,
          GFA::Line::Link::FieldCast,
          validate: validate)
  end

  include GFA::SegmentReferences

  def from_end
    [from, from_orient == "+" ? :E : :B]
  end

  def to_end
    [to, to_orient == "+" ? :B : :E]
  end

  def other_end(segment_end)
    if segment_end.size != 2 and ![:B, :E].include?(segment_end[1])
      raise "This is not a segment end #{segment_end.inspect}"
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
