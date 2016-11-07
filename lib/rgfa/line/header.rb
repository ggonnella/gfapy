# A header line of a RGFA file
#
# For examples on how to set the header data, see {RGFA::Headers}.
#
# @see RGFA::Line
class RGFA::Line::Header < RGFA::Line

  RECORD_TYPE = :H
  POSFIELDS = []
  REFERENCE_FIELDS = []
  PREDEFINED_TAGS = [:VN]
  FIELD_ALIAS = {}
  DATATYPE = {
    :VN => :Z
  }

  define_field_methods!

end

require_relative "header/version_conversion.rb"
require_relative "header/multiline.rb"
require_relative "header/connection.rb"

class RGFA::Line::Header
  include RGFA::Line::Header::VersionConversion
  include RGFA::Line::Header::Multiline
  include RGFA::Line::Header::Connection
end
