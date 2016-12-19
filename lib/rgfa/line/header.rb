# A header line of a RGFA file
#
# @tested_in api_header
class RGFA::Line::Header < RGFA::Line

  RECORD_TYPE = :H
  POSFIELDS = []
  PREDEFINED_TAGS = [:VN, :TS]
  FIELD_ALIAS = {}
  DATATYPE = {
    :VN => :Z,
    :TS => :i
  }
  REFERENCE_FIELDS = []
  NAME_FIELD = nil
  STORAGE_KEY = :merge
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  apply_definitions

end

require_relative "header/version_conversion.rb"
require_relative "header/multiline.rb"
require_relative "header/connection.rb"
require_relative "header/field_data.rb"

class RGFA::Line::Header
  include RGFA::Line::Header::VersionConversion
  include RGFA::Line::Header::Multiline
  include RGFA::Line::Header::Connection
  include RGFA::Line::Header::FieldData
end
