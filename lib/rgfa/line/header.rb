# A header line of a RGFA file
class RGFA::Line::Header < RGFA::Line

  RECORD_TYPE = "H"

  # @note The field names are derived from the RGFA specification at:
  #   https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#header-line
  #   and were made all downcase with _ separating words
  REQFIELD_DEFINITIONS = []
  REQFIELD_CAST = {}

  # Predefined optional fields
  OPTFIELD_TYPES = {
     "VN" => "Z", # Version number
    }

end
