require "json"

module RGFA::Datastrings

  # A symbol representing a datatype for optional fields
  OPTFIELD_DATATYPE = [:A, :i, :f, :Z, :J, :H, :B]

  # A symbol representing a datatype for required fields
  REQFIELD_DATATYPE = [:lbl, :orn, :lbs, :seq, :pos, :cig, :cgs]

  # A symbol representing a valid datatype
  DATATYPE_SYMBOL = OPTFIELD_DATATYPE + REQFIELD_DATATYPE

  VALIDATION_REGEXP = {
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
    :lbs => /^[!-)+-<>-~][!-~]*[+-](,[!-)+-<>-~][!-~]*[+-])*$/,
                           # multiple labels with orientations, comma-sep
    :seq => /^\*|[A-Za-z=.]+$/,          # nucleotide sequence
    :pos => /^[0-9]*$/,                  # positive integer
    :cig => /^\*|([0-9]+[MIDNSHPX=])+$/, # CIGAR string
    :cgs => /^\*|([0-9]+[MIDNSHPX=])+((,[0-9]+[MIDNSHPX=])+)*$/,
                                       # multiple CIGARs, comma-sep
  }

end

#
# Methods to convert from/to and validate the string representations of
# the fields data
#
class String

  # Validates the string according to the provided datatype
  # @param datatype [RGFA::Datastring::DATATYPE_SYMBOL]
  # @param fieldname [#to_s] Fieldname to use in the error msg
  # @raise [RGFA::Line::FieldFormatError] if the string does not match
  #   the regexp for the provided datatype
  # @return [void]
  def validate_datastring(datatype, fieldname: nil)
    regexp = RGFA::Datastrings::VALIDATION_REGEXP.fetch(datatype)
    if (self =~ regexp) != 0
      fieldname ||= "Value"
      raise RGFA::Line::FieldFormatError,
        "#{fieldname}: #{self.inspect}\n"+
        "Wrong format, expected: #{regexp}"
    end
    return nil
  end

  # data types which are not parsed if lazy mode is used
  DELAY_CAST = [:cig, :cgs, :lbs, :H, :J, :B]

  def parse_datastring(datatype, validate: true, lazy: true, fieldname: nil)
    validate_datastring(datatype, fieldname: fieldname) if validate
    return self if lazy and DELAY_CAST.include?(datatype)
    case datatype
    when :A, :Z, :seq
      return self
    when :lbl, :orn
      return to_sym
    when :i, :pos
      return Integer(self)
    when :f
      return Float(self)
    when :H
      return to_byte_array(validate: validate)
    when :B
      return to_numeric_array(validate: validate)
    when :J
      return JSON.parse(self)
    when :cig
      return cigar_operations
    when :cgs
      return split(",").map{|c|c.cigar_operations}
    when :lbs
      return split(",").map{|l| [l[0..-2].to_sym,
                                 l[-1].to_sym].to_oriented_segment}
    else
      raise "Datatype unknown: #{datatype}"
    end
  end

end

class Object
  # Representation of an object as GFA field
  # @return [String] the GFA field content
  # @param datatype [Symbol, nil] <i>(default: +nil+)
  #   one of the provided GFA datatypes;
  #   if +nil+, it is determined using the #gfa_datatype method
  # @param validate [Boolean] <i>(default: +true+)</i>
  #   validate the data string using the predefined regular
  #   expression, depending on the datatype
  # @param fieldname [Symbol, nil] <i>(default: +nil+)</i>
  #   fieldname to use for error messages and for the
  #   output if +optfield+ is true
  # @param optfield [Boolean] <i>(default: +false+)</i>
  #   if true, the output will contain
  #   field name, datatype symbol and datastring joined by +:+;
  #   otherwise only the datastring is returned
  def to_gfa_field(datatype: nil, validate: true,
                  fieldname: nil, optfield: false)
    datatype ||= self.gfa_datatype
    s = to_gfa_datastring(datatype)
    s.validate_datastring(datatype, fieldname: fieldname) if validate
    return optfield ? "#{fieldname}:#{datatype}:#{s}" : s
  end
  # Representation of the data for GFA fields
  # @return [String]
  # @param datatype [GFA::Line::DATATYPE]
  def to_gfa_datastring(datatype)
    to_s
  end
  def gfa_datatype; :Z; end
end

class Integer
  def gfa_datatype; :i; end
end

class Float
  def gfa_datatype; :f; end
end

class Array
  def to_gfa_datastring(datatype)
    case datatype
    when :B
      to_numeric_array.to_gfa_datastring(:B)
    when :J
      to_json
    when :cig
      flatten.join
    when :cgs
      map{|cig|cig.to_gfa_datastring(:cig)}.join(",")
    when :lbs
      map{|os|os.to_oriented_segment.join}.join(",")
    when :H
      to_byte_array.to_gfa_datastring(:H)
    else
      map(&:to_s).join(",")
    end
  end
  def gfa_datatype
    if all?{|i|i.kind_of?(Integer)} or all?{|i|i.kind_of?(Float)}
      :B
    else
      :J
    end
  end
end

class Hash
  def to_gfa_datastring(datatype)
    to_json
  end
  def gfa_datatype
    :J
  end
end

