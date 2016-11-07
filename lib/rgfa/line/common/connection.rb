module RGFA::Line::Common::Connection

  # In a connected line, some of the fields are converted
  # into references or array of references to other lines.
  # Furthermore instance variables are populated with back
  # references to the line (e.g. connection of a segment
  # are stored as references in segment arrays), to allow
  # graph traversal.
  # @return [Boolean] is the line connected to other lines of a RGFA instance?
  def connected?
    !@rgfa.nil?
  end

  attr_reader :rgfa

  # Connect the line to a RGFA instance
  # @param rgfa [RGFA] the RGFA instance
  # @return [void]
  def connect(rgfa)
    if connected?
      raise RGFA::RuntimeError,
        "Line #{self} is already connected to a RGFA instance"
    end
    previous = rgfa.search_duplicate(self)
    if !previous.nil?
      if previous.record_type == record_type and previous.virtual?
        raise RGFA::NotFoundError if rgfa.segments_first_order
        merge_virtual(previous)
        rgfa.unregister_line(previous)
      else
        process_line_not_unique(previous)
        return nil
      end
    end
    @rgfa = rgfa
    create_references
    @rgfa.register_line(self)
    return nil
  end

  # Remove the line from the RGFA instance it belongs to, if any.
  #
  # The Line instance itself will still exist, but all references from it to
  # other lines are deleted, as well as references to it from other lines.
  # Mandatory references are turned into their non-reference representations
  # (e.g. segments references in the sid fields of E lines
  # or in the from/to lines of L/C lines are changed into symbols).
  #
  # @return [void]
  def disconnect!
    if !connected?
      raise RGFA::RuntimeError,
        "Line #{self} is not to a RGFA instance"
    end
    remove_references
    @rgfa.unregister_line(self)
    @rgfa = nil
  end

  # Is the line virtual?
  #
  # Is this RGFA::Line a virtual line representation
  # (i.e. a placeholder for an expected but not encountered yet line)?
  # @api private
  # @return [Boolean]
  def virtual?
    @virtual
  end

  # Make a virtual line real.
  # @api private
  # This is called when a line which is expected, and for which a virtual
  # line has been created, is finally found. So the line is converted into
  # a real line, by merging in the line information from the found line.
  # @param real_line [RGFA::Line] the real line fou
  def real!(real_line)
    @virtual = false
    real_line.data.each_pair do |k, v|
      @data[k] = v
    end
  end

  private

  # can be overwritten by subclasses
  def create_references
  end

  # can be overwritten by subclasses
  def remove_references
  end

  # can be overwritten by subclasses
  def process_line_not_unique(previous)
    raise RGFA::NotUniqueError,
      "Line: #{self.to_s}\n"+
      "Line or ID not unique\n"+
      "Matching previous line: #{previous.to_s}"
  end

  # can be overwritten by subclasses
  def merge_virtual(previous)
  end

end
