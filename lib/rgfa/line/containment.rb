require_relative "../segment_references.rb"

# A containment line of a RGFA file
class RGFA::Line::Containment < RGFA::Line

  RECORD_TYPE = "C"

  # @note The field names are derived from the RGFA specification at:
  #   https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#containment-line
  #   and were made all downcase with _ separating words
  REQFIELD_DEFINITIONS = [
     [:from,        /[!-)+-<>-~][!-~]*/],      # name of segment
     [:from_orient, /\+|-/],                   # orientation of From segment
     [:to,          /[!-)+-<>-~][!-~]*/],      # name of segment
     [:to_orient,   /\+|-/],                   # orientation of To segment
     [:pos,         /[0-9]*/],                 # 0-based startpos of contained
     [:overlap,     /\*|([0-9]+[MIDNSHPX=])+/] # CIGAR string describing overlap
    ]

  # Procedures for the conversion of selected required fields to Ruby types
  REQFIELD_CAST = {
      :pos =>     lambda {|e| e.to_i },
      :overlap => lambda {|e| e.cigar_operations }
    }

  # Predefined optional fields
  OPTFIELD_TYPES = {
     "MQ" => "i", # Mapping quality
     "NM" => "i", # Number of mismatches/gaps
    }

  include RGFA::SegmentReferences

end
