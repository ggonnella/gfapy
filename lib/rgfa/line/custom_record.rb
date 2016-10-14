# A custom line of a GFA2 file
# "Any line that does not begin with a recognized code can be ignored.
#  This will allow users to have additional descriptor lines specific to their
#  special processes."
#
# Parsing of custom lines will be handled as follows:
# - divide content by tabs
# - from the back, fields are parsed using parse_optional_field;
#   until an exception is thrown, they are all considered optional fields
# - from the first exception to the first field, they are all considered
#   required fields with name field0, field1, etc
#
class RGFA::Line::CustomRecord < RGFA::Line

  RECORD_TYPE = nil
  REQFIELDS = {:"1.0" => nil,
               :"2.0" => [:record_type]}
  FIELD_ALIAS = {}
  PREDEFINED_OPTFIELDS = []
  DATATYPE = {
    :record_type => :crt,
  }

  define_field_methods!

  def required_fieldnames
    @required_fieldnames
  end

  def optional_fieldnames
    (@data.keys - @required_fieldnames - [:record_type])
  end
  private

  def initialize_required_fields(strings)
    # delayed, see #delayed_inizialize_required_fields
  end

  def initialize_optional_fields(strings)
    first_optional = strings.size
    (strings.size-1).downto(1) do |i|
      initialize_optional_field(*strings[i].parse_gfa_optfield) rescue break
      first_optional = i
    end
    delayed_initialize_required_fields(strings, first_optional)
  end

  def delayed_initialize_required_fields(strings, n_required_fields)
    @required_fieldnames = []
    init_field_value(:record_type, :crt, strings[0])
    1.upto(n_required_fields-1) do |i|
      n = :"field#{i}"
      init_field_value(n, :any, strings[i])
      @required_fieldnames << n
      @datatype[n] = :any
    end
  end

end
