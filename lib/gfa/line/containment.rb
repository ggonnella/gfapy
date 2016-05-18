class GFA::Line::Containment < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#containment-line
  # note: the field names were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type, /C/],
     [:from,        /[!-)+-<>-~][!-~]*/], # name of segment
     [:from_orient, /\+|-/],              # orientation of From segment
     [:to,          /[!-)+-<>-~][!-~]*/], # name of segment
     [:to_orient,   /\+|-/],              # orientation of To segment
     [:pos,         /[0-9]*/],            #  0-based start of contained segment
     [:overlap,     /\*|([0-9]+[MIDNSHPX=])+/] # CIGAR string describing overlap
    ]

  FieldCast =
    { :pos => lambda {|e| e.to_i},
      :overlap => lambda {|e| e.cigar_operations} }

  OptfieldTypes = {
     "RC" => "i", # Read Coverage
     "NM" => "i", # Number of mismatches/gaps
    }

  def initialize(fields)
    super(fields,
          GFA::Line::Containment::FieldRegexp,
          GFA::Line::Containment::OptfieldTypes,
          GFA::Line::Containment::FieldCast)
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

end
