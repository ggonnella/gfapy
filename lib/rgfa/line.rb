require "set"

#
# Generic representation of a record of a RGFA file.
#
# @!macro [new] rgfa_line
#   @note
#     This class is usually not meant to be directly initialized by the user;
#     initialize instead one of its child classes, which define the concrete
#     different record types.
#
class RGFA::Line

  # Separator in the string representation of RGFA lines
  SEPARATOR = "\t"

  # List of allowed record_type values
  RECORD_TYPES = [ :H, :S, :L, :C, :P, :"#", :G, :F, :E, :O, :U, nil ]

  # Direction of a segment for links/containments
  DIRECTION = [:from, :to]

  # Orientation of segments in paths/links/containments
  ORIENTATION = [:+, :-]

  # @!attribute [r] version
  #   @return [RGFA::VERSIONS, nil] GFA specification version
  attr_reader :version

  # @return [Symbol] record type code
  def record_type
    self.class::RECORD_TYPE
  end

  # @return self
  # @param validate [Boolean] ignored (compatibility reasons)
  # @param version [Boolean] ignored (compatibility reasons)
  def to_rgfa_line(validate: nil, version: nil)
    self
  end

end

# submodules of RGFA::Line::Common define methods which are included
# in line or in its subclasses
RGFA::Line::Common = Module.new

require_relative "line/common/init"
require_relative "line/common/dynamic_fields"
require_relative "line/common/writer"
require_relative "line/common/version_conversion"
require_relative "line/common/field_datatype"
require_relative "line/common/field_data"
require_relative "line/common/equivalence"
require_relative "line/common/cloning"
require_relative "line/common/connection"
require_relative "line/common/virtual_to_real"
require_relative "line/common/update_references"
require_relative "line/common/disconnection"
require_relative "line/common/validate"

class RGFA::Line
  include RGFA::Line::Common::Init
  include RGFA::Line::Common::DynamicFields
  include RGFA::Line::Common::Writer
  include RGFA::Line::Common::VersionConversion
  include RGFA::Line::Common::FieldDatatype
  include RGFA::Line::Common::FieldData
  include RGFA::Line::Common::Equivalence
  include RGFA::Line::Common::Cloning
  include RGFA::Line::Common::Connection
  include RGFA::Line::Common::VirtualToReal
  include RGFA::Line::Common::UpdateReferences
  include RGFA::Line::Common::Disconnection
  include RGFA::Line::Common::Validate

  # TODO: can this be moved to dynamic fields

  #
  # This avoids calls to method_missing for fields which are already defined
  #
  def self.define_field_methods
    (self::POSFIELDS +
     self::PREDEFINED_TAGS).each do |fieldname|
      define_method(fieldname) do
        get(fieldname)
      end
      define_method :"#{fieldname}!" do
        get!(fieldname)
      end
      define_method :"#{fieldname}=" do |value|
        set_existing_field(fieldname, value)
      end
    end
    self::FIELD_ALIAS.each do |k,v|
      alias_method :"#{k}",  :"#{v}"
      alias_method :"#{k}!", :"#{v}!"
      alias_method :"#{k}=", :"#{v}="
    end
    (self::DEPENDENT_LINES + self::OTHER_REFERENCES).each do |k|
      define_method(k) do
        @refs ||= {}
        @refs.fetch(k, []).clone.freeze
      end
    end
    define_method :all_references do
      refs.values.flatten
    end
  end
  private_class_method :define_field_methods

end

#
# Require the child classes
#
require_relative "line/header.rb"
require_relative "line/segment.rb"
require_relative "line/comment.rb"
require_relative "line/custom_record.rb"
require_relative "line/gap.rb"
require_relative "line/fragment.rb"
require_relative "line/edge.rb"
require_relative "line/group.rb"
require_relative "line/unknown.rb"
