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

  def initialize(fields)
    super(fields,
          GFA::Line::Link::FieldRegexp,
          GFA::Line::Link::OptfieldTypes,
          GFA::Line::Link::FieldCast)
  end

  def other(segment_name)
    if segment_name == from
      to
    elsif segment_name == to
      from
    else
      raise "Link #{self} does not involve segment #{segment_name}"
    end
  end

  def orient(segment_name)
    if segment_name == from
      from_orient
    elsif segment_name == to
      to_orient
    else
      raise "Link #{self} does not involve segment #{segment_name}"
    end
  end

  def other_orient(segment_name)
    orient(other(segment_name))
  end

  def end_type(segment_name)
    if segment_name == from
      return from_orient == "+" ? :E : :B
    elsif segment_name == to
      return to_orient == "+" ? :B : :E
    else
      raise "Link #{self} does not involve segment #{segment_name}"
    end
  end

end
