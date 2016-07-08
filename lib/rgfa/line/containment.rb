require_relative "../segment_references.rb"

# A containment line of a RGFA file
class RGFA::Line::Containment < RGFA::Line

  # @note The field names are derived from the RGFA specification at:
  #   https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#containment-line
  #   and were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type, /C/],
     [:from,        /[!-)+-<>-~][!-~]*/],      # name of segment
     [:from_orient, /\+|-/],                   # orientation of From segment
     [:to,          /[!-)+-<>-~][!-~]*/],      # name of segment
     [:to_orient,   /\+|-/],                   # orientation of To segment
     [:pos,         /[0-9]*/],                 # 0-based startpos of contained
     [:overlap,     /\*|([0-9]+[MIDNSHPX=])+/] # CIGAR string describing overlap
    ]

  # Procedures for the conversion of selected required fields to Ruby types
  FieldCast = {
      :pos =>     lambda {|e| e.to_i },
      :overlap => lambda {|e| e.cigar_operations }
    }

  # Predefined optional fields
  OptfieldTypes = {
     "MQ" => "i", # Mapping quality
     "NM" => "i", # Number of mismatches/gaps
    }

  # @param fields [Array<String>] splitted content of the line
  # @param validate [Boolean] <i>(defaults to: +true+)</i>
  #   perform validations?
  # @return [RGFA::Line::Link]
  def initialize(fields, validate: true)
    super(fields,
          RGFA::Line::Containment::FieldRegexp,
          RGFA::Line::Containment::OptfieldTypes,
          RGFA::Line::Containment::FieldCast,
          validate: validate)
  end

  include RGFA::SegmentReferences

end
