# Allow to parse as tags all fields which are valid GFA tags on the right end
# of the line
# @tested_in api_custom_records
module RGFA::Line::CustomRecord::Init

  # List of names of positional fields (:field1, :field2, ...)
  # @return [Array<Symbol>]
  def positional_fieldnames
    @positional_fieldnames
  end

  # List of tag names
  # @return [Array<Symbol>]
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
    if ["P", "C", "L"].include?(strings[0])
      raise RGFA::VersionError,
        "GFA-like line (P,C,L) found in GFA2\n"+
        "Line: #{strings.join(' ')}\n"+
        "Custom lines with record_type P, C and L are not supported by RGFA."
    end
    init_field_value(:record_type, :custom_record_type, strings[0],
                     errmsginfo: strings)
    1.upto(n_positional_fields-1) do |i|
      n = :"field#{i}"
      init_field_value(n, :generic, strings[i], errmsginfo: strings)
      @positional_fieldnames << n
      @datatype[n] = :generic
    end
  end

end
