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
class RGFA::Line; end

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
