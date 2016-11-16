module RGFA::Line::Common::ReferencesCreation

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
      if previous.virtual?
        return substitute_virtual_line(previous)
      else
        return process_not_unique(previous)
      end
    else
      @rgfa = rgfa
      initialize_references
      @rgfa.register_line(self)
      return nil
    end
  end

  # @api private
  def add_reference(line, key, append: true)
    refs[key] ||= []
    if append
      @refs[key] += [line]
    else
      @refs[key] = [line] + @refs[key]
    end
    @refs[key].freeze
  end

  protected

  def refs
    @refs ||= {}
  end

  private

  # @note SUBCLASSES with reference fields shall
  #   overwrite this method to connect their reference
  #   fields
  def initialize_references
  end

  # @note SUBCLASSES may overwrite this method
  #   if some kind of non unique lines shall be
  #   tolerated or handled differently (eg complement links)
  def process_not_unique(previous)
    raise RGFA::NotUniqueError,
      "Line: #{self.to_s}\n"+
      "Line or ID not unique\n"+
      "Matching previous line: #{previous.to_s}"
  end

end
