module RGFA::Line::Common::Equivalence

  # Equivalence check
  # @return [Boolean] does the line has the same record type,
  #   contains the same tags
  #   and all positional fields and tags contain the same field values?
  # @see RGFA::Line::Link#==
  def ==(o)
    return self.to_sym == o.to_sym if o.kind_of?(Symbol)
    return false if (o.record_type != self.record_type)
    return false if o.data.keys.sort != data.keys.sort
    o.data.each do |k, v|
      if @data[k] != o.data[k]
        if field_to_s(k) != o.field_to_s(k)
          return false
        end
      end
    end
    return true
  end

  protected

  def data
    @data
  end

  def datatype
    @datatype
  end

end
