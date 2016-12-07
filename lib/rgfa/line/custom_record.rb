# A custom line of a GFA2 file
# "Any line that does not begin with a recognized code can be ignored.
#  This will allow users to have additional descriptor lines specific to their
#  special processes."
#
# Parsing of custom lines is handled as follows:
# - divide content by tabs
# - from the back, fields are parsed using parse_gfa_tag;
#   until an exception is thrown, they are all considered tags
# - from the first exception to the first field, they are all considered
#   positional fields with name field0, field1, etc
#
class RGFA::Line::CustomRecord < RGFA::Line

  RECORD_TYPE = nil
  POSFIELDS = [:record_type]
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :record_type => :custom_record_type,
  }
  REFERENCE_FIELDS = []
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  apply_definitions
end

require_relative "custom_record/init.rb"

class RGFA::Line::CustomRecord
  include RGFA::Line::CustomRecord::Init
end
