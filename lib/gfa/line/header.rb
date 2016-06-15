# A header line of a GFA file
class GFA::Line::Header < GFA::Line

  # @note The field names are derived from the GFA specification at:
  #   https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#header-line
  #   and were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type, /H/]
    ]

  # Predefined optional fields
  OptfieldTypes = {
     "VN" => "Z", # Version number
    }

  # @param fields [Array<String>] splitted content of the line
  # @param validate [Boolean] <i>(defaults to: +true+)</i>
  #   perform validations?
  # @return [GFA::Line::Link]
  def initialize(fields, validate: true)
    super(fields, GFA::Line::Header::FieldRegexp,
          GFA::Line::Header::OptfieldTypes, validate: validate)
  end

end
