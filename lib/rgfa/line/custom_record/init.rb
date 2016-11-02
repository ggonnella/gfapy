module RGFA::Line::CustomRecord::Init

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
    init_field_value(:record_type, :custom_record_type, strings[0])
    1.upto(n_positional_fields-1) do |i|
      n = :"field#{i}"
      init_field_value(n, :generic, strings[i])
      @positional_fieldnames << n
      @datatype[n] = :generic
    end
  end

end
