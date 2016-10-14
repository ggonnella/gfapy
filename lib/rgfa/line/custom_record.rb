# A custom line of a GFA2 file
# "Any line that does not begin with a recognized code can be ignored.
#  This will allow users to have additional descriptor lines specific to their
#  special processes."
#
# Parsing of custom lines will be handled as follows:
# - divide content by tabs
# - from the back, fields are parsed using parse_gfa_tag;
#   until an exception is thrown, they are all considered tags
# - from the first exception to the first field, they are all considered
#   positional fields with name field0, field1, etc
#
class RGFA::Line::CustomRecord < RGFA::Line

  RECORD_TYPE = nil
  POSFIELDS = {:"1.0" => nil,
               :"2.0" => [:record_type]}
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :record_type => :crt,
  }

  define_field_methods!

  def positional_fieldnames
    @positional_fieldnames
  end

  def tagnames
    (@data.keys - @positional_fieldnames - [:record_type])
  end
  private

  def initialize_positional_fields(strings)
    # delayed, see #delayed_inizialize_positional_fields
  end

  def initialize_tags(strings)
    first_tag = strings.size
    (strings.size-1).downto(1) do |i|
      initialize_tag(*strings[i].parse_gfa_tag) rescue break
      first_tag = i
    end
    delayed_initialize_positional_fields(strings, first_tag)
  end

  def delayed_initialize_positional_fields(strings, n_positional_fields)
    @positional_fieldnames = []
    init_field_value(:record_type, :crt, strings[0])
    1.upto(n_positional_fields-1) do |i|
      n = :"field#{i}"
      init_field_value(n, :any, strings[i])
      @positional_fieldnames << n
      @datatype[n] = :any
    end
  end

end
