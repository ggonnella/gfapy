require_relative "field_parser"
require_relative "line"

#
# Methods to validate the string representations of the GFA fields data
# @api private
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
    :aln => /^(\*|(([0-9]+[MIDNSHPX=])+)|((\d+)(,\d+)*))$/, # CIGAR or trace
    :cgs => /^(\*|(([0-9]+[MIDNSHPX=])+))(,(\*|(([0-9]+[MIDNSHPX=])+)))*$/,
                                       # multiple CIGARs, comma-sep
    :any => /.*/, # content of comment line, everything is allowed
    :crt => /.*/, # custom record type, everything is allowed,
  }

  # Validates the string according to the provided datatype
  # @param datatype [RGFA::Line::FIELD_DATATYPE]
  # @param fieldname [#to_s] Fieldname to use in the error msg
  # @raise [RGFA::FieldParser::FormatError] if the string does not match
  #   the regexp for the provided datatype
  # @return [void]
  # @api private
  def validate_gfa_field!(datatype, fieldname=nil)
    regexp = DATASTRING_VALIDATION_REGEXP[datatype]
    raise RGFA::FieldParser::UnknownDatatypeError if regexp.nil?
    if (regexp !~ self)
      fieldname ||= "Value"
      raise RGFA::FieldParser::FormatError,
        "Wrong format for field #{fieldname}: \n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}\n"+
        "Expected regex: #{regexp}\n"
    end
  end

  # Validates segment names, to check that they do not contain + or -
  # followed by comma
  # @raise [RGFA::FieldParser::FormatError] if the segment name is invalid
  # @return [void]
  # @api private
  def validate_segment_name!
    if self =~ /.*[+-],.*/
      raise RGFA::FieldParser::FormatError,
      "Segment names are not allowed to contain +/- followed by comma "+
      "(found: #{self})"
    end
  end

end

class String
  include RGFA::FieldValidator
end

class Object
  # @!macro [new] validate_gfa_field
  #   Validates the object according to the provided datatype
  #   @param datatype [RGFA::Line::FIELD_DATATYPE]
  #   @param fieldname [#to_s] Fieldname to use in the error msg
  #   @raise [RGFA::FieldParser::FormatError] if the object type or content
  #     is not compatible to the provided datatype
  #   @return [void]
  #   @api private
  def validate_gfa_field!(datatype, fieldname=nil)
    raise RGFA::FieldParser::FormatError,
      "Wrong type (#{self.class}) for field #{fieldname}\n"+
      "Content: #{self.inspect}\n"+
      "Datatype: #{datatype}"
  end
end

class Symbol
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :lbl and datatype != :orn and
         datatype != :Z and datatype != :crt
      raise RGFA::FieldParser::FormatError,
        "Wrong type (#{self.class}) for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}"
    end
    self.to_s.validate_gfa_field!(datatype)
  end
end

class Hash
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :J
      raise RGFA::FieldParser::FormatError,
        "Wrong type (#{self.class}) for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}"
    end
  end
end

class Array
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    begin
      case datatype
      when :J
        return
      when :Z
        return
      when :lbs
        map!(&:to_oriented_segment).each(&:validate!)
        return
      when :cig
        to_alignment(false).validate!
        return
      when :cgs
        each{|elem| elem.to_alignment(false).validate!}
        return
      when :B
        to_numeric_array.validate!
        return
      when :H
        to_byte_array.validate!
        return
      end
    rescue => err
      raise RGFA::FieldParser::FormatError,
        "Invalid content for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}\n"+
        "Error: #{err}"
    end
    raise RGFA::FieldParser::FormatError,
        "Wrong type (#{self.class}) for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}"
  end
end

class RGFA::ByteArray
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :H
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: #{self.inspect}\n"+
          "Datatype: #{datatype}"
    end
    begin
      validate!
    rescue => err
      raise RGFA::FieldParser::FormatError,
        "Invalid content for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}\n"+
        "Error: #{err}"
    end
  end
end

class RGFA::CIGAR
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :cig and datatype != :aln
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: #{self.inspect}\n"+
          "Datatype: #{datatype}"
    end
    begin
      validate!
    rescue => err
      raise RGFA::FieldParser::FormatError,
        "Invalid content for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}\n"+
        "Error: #{err}"
    end
  end
end

class RGFA::Trace
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :aln
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: #{self.inspect}\n"+
          "Datatype: #{datatype}"
    end
    begin
      validate!
    rescue => err
      raise RGFA::FieldParser::FormatError,
        "Invalid content for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}\n"+
        "Error: #{err}"
    end
  end
end

class RGFA::Placeholder
  # Datatypes which can be represented by a placeholder
  DATATYPES = [:aln, :cig, :seq]

  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if !RGFA::Placeholder::DATATYPES.include?(datatype)
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: #{self.inspect}\n"+
          "Datatype: #{datatype}"
    end
  end
end

class RGFA::NumericArray
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :B
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: #{self.inspect}\n"+
          "Datatype: #{datatype}"
    end
    begin
      validate!
    rescue => err
      raise RGFA::FieldParser::FormatError,
        "Invalid content for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}\n"+
        "Error: #{err}"
    end
  end
end

class Float
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :f and datatype != :Z
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: #{self.inspect}\n"+
          "Datatype: #{datatype}"
    end
  end
end

class Fixnum
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if (datatype == :pos and self < 0)
      raise RGFA::FieldParser::FormatError,
        "Invalid content for field #{fieldname}\n"+
        "Content: #{self.inspect}\n"+
        "Datatype: #{datatype}"
    elsif ![:i, :f, :Z].include?(datatype)
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: #{self.inspect}\n"+
          "Datatype: #{datatype}"
    end
  end
end

class RGFA::Line::Segment
  # @!macro validate_gfa_field
  def validate_gfa_field!(datatype, fieldname=nil)
    if datatype != :lbl
      raise RGFA::FieldParser::FormatError,
          "Wrong type (#{self.class}) for field #{fieldname}\n"+
          "Content: <RGFA::Segment:#{self.to_s}>\n"+
          "Datatype: #{datatype}"
    end
  end
end
