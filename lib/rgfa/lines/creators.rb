#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::Lines::Creators

  # Add a line to a RGFA
  #
  # @overload <<(gfa_line_string)
  #   @param [String] gfa_line_string representation of a RGFA line
  # @overload <<(gfa_line)
  #   @param [RGFA::Line] gfa_line instance of a subclass of RGFA::Line
  # @raise [RGFA::NotUniqueError] if multiple segment or path lines
  #   with the same name are added
  # @raise [RGFA::ArgumentError] if the argument is not a RGFA::Line or String
  # @return [RGFA] self
  def add_line(gfa_line)
    case version
    when :gfa1
      add_line_GFA1(gfa_line)
    when :gfa2
      add_line_GFA2(gfa_line)
    when nil
      add_line_unknown_version(gfa_line)
    else
      raise # This point should never be reached
    end
    return self
  end
  alias_method :<<, :add_line

  def add_line_unknown_version(gfa_line)
    if gfa_line.kind_of?(String)
      rt = gfa_line[0].to_sym
    elsif gfa_line.kind_of?(RGFA::Line)
      rt = gfa_line.record_type
    else
      raise RGFA::ArgumentError,
        "Only strings and RGFA::Line instances can be added"
    end
    case rt
    when :"#"
      gfa_line.to_rgfa_line(validate: @validate).connect(self)
    when :H
      gfa_line = gfa_line.to_rgfa_line(validate: @validate)
      header.merge(gfa_line)
      if gfa_line.VN
        @version = case gfa_line.VN
                   when "1.0" then :gfa1
                   when "2.0" then :gfa2
                   else gfa_line.VN.to_sym
                   end
        @version_explanation = "specified in header VN tag"
        validate_version if @validate > 0
        @line_queue.size.times {self << @line_queue.shift}
      end
    when :S
      gfa_line = gfa_line.to_rgfa_line(validate: @validate)
      @version = gfa_line.version
      @version_explanation = "implied by: syntax of S #{gfa_line.name} line"
      process_line_queue
      gfa_line.connect(self)
    when :E, :F, :G, :U, :O
      @version = :gfa2
      @version_explanation = "implied by: presence of a #{rt} line"
      gfa_line = gfa_line.to_rgfa_line(validate: @validate, version: @version)
      process_line_queue
      gfa_line.connect(self)
    when :L, :C, :P
      @version_guess = :gfa1
      @line_queue << gfa_line
    else
      @line_queue << gfa_line
    end
  end
  private :add_line_unknown_version

  def add_line_GFA1(gfa_line)
    if gfa_line.kind_of?(String)
      gfa_line = gfa_line.to_rgfa_line(version: :gfa1, validate: @validate)
    elsif RGFA::Lines::GFA2Specific.include?(gfa_line.class)
      raise RGFA::VersionError,
        "Version: 1.0 (#{@version_explanation})\t"+
        "Cannot add instance of incompatible line type "+
        "(#{gfa_line.class})"
    end
    case gfa_line.record_type
    when :H
      if @validate > 0 and gfa_line.VN and gfa_line.VN.to_sym != :gfa1
        raise RGFA::VersionError,
          "Header line specified wrong version (#{gfa_line.VN})\n"+
          "Line: #{gfa_line}\n"+
          "File version: 1.0 (#{@version_explanation})"
      end
      header.merge(gfa_line)
    when :S, :L, :P, :C, :"#"
      gfa_line.connect(self)
    else
      raise RGFA::TypeError,
        "Invalid record type #{rt}" # should be unreachable
    end
  end
  private :add_line_GFA1

  def add_line_GFA2(gfa_line)
    if gfa_line.kind_of?(String)
      gfa_line = gfa_line.to_rgfa_line(version: :gfa2, validate: @validate)
    elsif RGFA::Lines::GFA1Specific.include?(gfa_line.class)
      raise RGFA::VersionError,
        "Version: 2.0 (#{@version_explanation})\t"+
        "Cannot add instance of incompatible line type "+
        "(#{gfa_line.class})"
    end
    case gfa_line.record_type
    when :H
      if @validate > 0 and gfa_line.VN and gfa_line.VN.to_sym != :gfa2
        raise RGFA::VersionError,
          "Header line specified wrong version (#{gfa_line.VN})\n"+
          "Line: #{gfa_line}\n"+
          "File version: 2.0 (#{@version_explanation})"
      end
      header.merge(gfa_line)
    else
      gfa_line.connect(self)
    end
  end
  private :add_line_GFA2

  def process_line_queue
    if @version.nil?
      @version = @version_guess
    end
    @line_queue.size.times {self << @line_queue.shift}
  end

  # @api private
  def register_line(gfa_line)
    api_private_check_gfa_line(gfa_line, "register_line")
    if gfa_line.respond_to?(:name)
      @records[gfa_line.record_type] ||= {}
      if gfa_line.name.empty?
        @records[gfa_line.record_type][nil] ||= []
        @records[gfa_line.record_type][nil] << gfa_line
      else
        @records[gfa_line.record_type][gfa_line.name] = gfa_line
      end
    else
      case gfa_line.record_type
      when :H
        @records[:H].merge(gfa_line)
      when :F
        @records[:F][gfa_line.external.line] ||= []
        @records[:F][gfa_line.external.line] << gfa_line
      else
        @records[gfa_line.record_type] ||= []
        @records[gfa_line.record_type] << gfa_line
      end
    end
  end

end
