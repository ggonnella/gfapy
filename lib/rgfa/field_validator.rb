require_relative "field_parser"

#
# Methods to validate the string representations of the GFA fields data
#
module RGFA::FieldValidator

  # Validation regular expressions, derived from the GFA specification
  DATASTRING_VALIDATION_REGEXP = {
    :A => /^[!-~]$/,         # Printable character
    :i => /^[-+]?[0-9]+$/,   # Signed integer
    :f => /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/,
                           # Single-precision floating number
    :Z => /^[ !-~]+$/,       # Printable string, including space
    :J => /^[ !-~]+$/,       # JSON, excluding new-line and tab characters
    :H => /^[0-9A-F]+$/,     # Byte array in the Hex format
    :B => /^[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+$/,
                           # Integer or numeric array
    :lbl => /^[!-)+-<>-~][!-~]*$/,       # segment/path label
    :orn => /^\+|-$/,                    # segment orientation
    :lbs => /^[!-)+-<>-~][!-~]*[+-](,[!-)+-<>-~][!-~]*[+-])+$/,
                           # multiple labels with orientations, comma-sep
    :seq => /^\*$|^[A-Za-z=.]+$/,          # nucleotide sequence
    :pos => /^[0-9]*$/,                  # positive integer
    :cig => /^(\*|(([0-9]+[MIDNSHPX=])+))$/, # CIGAR string
    :cgs => /^(\*|(([0-9]+[MIDNSHPX=])+))(,(\*|(([0-9]+[MIDNSHPX=])+)))*$/,
                                       # multiple CIGARs, comma-sep
  }

  # Validates the string according to the provided datatype
  # @param datatype [RGFA::Line::FIELD_DATATYPE]
  # @param fieldname [#to_s] Fieldname to use in the error msg
  # @raise [RGFA::FieldParser::FormatError] if the string does not match
  #   the regexp for the provided datatype
  # @return [void]
  def validate_datastring(datatype, fieldname: nil)
    regexp = DATASTRING_VALIDATION_REGEXP[datatype]
    raise RGFA::FieldParser::UnknownDatatypeError if regexp.nil?
    if (regexp !~ self)
      fieldname ||= "Value"
      raise RGFA::FieldParser::FormatError,
        "#{fieldname}: #{self.inspect}\n"+
        "Wrong format, expected: #{regexp}"
    end
    return nil
  end

end

class String
  include RGFA::FieldValidator
end

