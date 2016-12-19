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
  #
  # @tested_in api_lines_creators
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

  # Process the lines in the line queue in which lines of type P,L,C are put
  # during parsing while waiting for an additional signal which allows to
  # identify the version as GFA1.
  #
  # The user usually does not need to call this method, unless a RGFA is created
  # from scratch in memory and the user wants to do something on an incomplete
  # or invalid GFA (as any valid GFA will contain segments, it will call this
  # method automatically).
  #
  # @tested_in api_lines_version
  #
  # @return [void]
  def process_line_queue
    if @version.nil?
      @version = @version_guess
    end
    @line_queue.size.times {self << @line_queue.shift}
  end

  # @api private
  module API_PRIVATE

    # Register a line in the RGFA, i.e. add a reference to the
    # appropriate reference collection in the @records hash.
    #
    # @tested_in unit_rgfa_lines
    #
    # @return [void]
    def register_line(gfa_line)
      api_private_check_gfa_line(gfa_line, "register_line")
      storage_key = gfa_line.class::STORAGE_KEY
      case storage_key
      when :merge
        @records[gfa_line.record_type].merge(gfa_line)
      when :name
        @records[gfa_line.record_type] ||= {}
        if gfa_line.name.empty?
          @records[gfa_line.record_type][nil] ||= []
          @records[gfa_line.record_type][nil] << gfa_line
        else
          @records[gfa_line.record_type][gfa_line.name] = gfa_line
        end
      when :external
        @records[gfa_line.record_type][gfa_line.external.line] ||= []
        @records[gfa_line.record_type][gfa_line.external.line] << gfa_line
      when nil
        @records[gfa_line.record_type] ||= []
        @records[gfa_line.record_type] << gfa_line
      end
    end

  end
  include API_PRIVATE

  private

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
      gfa_line.to_rgfa_line(vlevel: @vlevel).connect(self)
    when :H
      gfa_line = gfa_line.to_rgfa_line(vlevel: @vlevel)
      header.merge(gfa_line)
      if gfa_line.VN
        @version = case gfa_line.VN
                   when "1.0" then :gfa1
                   when "2.0" then :gfa2
                   else gfa_line.VN.to_sym
                   end
        @version_explanation = "specified in header VN tag"
        validate_version if @vlevel > 0
        @line_queue.size.times {self << @line_queue.shift}
      end
    when :S
      gfa_line = gfa_line.to_rgfa_line(vlevel: @vlevel)
      @version = gfa_line.version
      @version_explanation = "implied by: syntax of S #{gfa_line.name} line"
      process_line_queue
      gfa_line.connect(self)
    when :E, :F, :G, :U, :O
      @version = :gfa2
      @version_explanation = "implied by: presence of a #{rt} line"
      gfa_line = gfa_line.to_rgfa_line(vlevel: @vlevel, version: @version)
      process_line_queue
      gfa_line.connect(self)
    when :L, :C, :P
      @version_guess = :gfa1
      @line_queue << gfa_line
    else
      @line_queue << gfa_line
    end
  end

  def add_line_GFA1(gfa_line)
    if gfa_line.kind_of?(String)
      if gfa_line[0] == "S"
        gfa_line = gfa_line.to_rgfa_line(vlevel: @vlevel)
      else
        gfa_line = gfa_line.to_rgfa_line(version: :gfa1, vlevel: @vlevel)
      end
    elsif RGFA::Lines::GFA2Specific.include?(gfa_line.class)
      raise RGFA::VersionError,
        "Version: 1.0 (#{@version_explanation})\n"+
        "Cannot add instance of incompatible line type "+
        "(#{gfa_line.class})"
    end
    case gfa_line.record_type
    when :H
      if @vlevel > 0 and gfa_line.VN and gfa_line.VN.to_sym != :"1.0"
        raise RGFA::VersionError,
          "Header line specified wrong version (#{gfa_line.VN})\n"+
          "Line: #{gfa_line}\n"+
          "File version: 1.0 (#{@version_explanation})"
      end
      header.merge(gfa_line)
    when :S
      if gfa_line.version == :gfa2
        raise RGFA::VersionError,
          "Version: 1.0 (#{@version_explanation})\n"+
          "GFA2 segment found: #{gfa_line}"
      end
      gfa_line.connect(self)
    when :L, :P, :C, :"#"
      gfa_line.connect(self)
    else
      raise RGFA::TypeError,
        "Invalid record type #{rt}" # should be unreachable
    end
  end

  def add_line_GFA2(gfa_line)
    if gfa_line.kind_of?(String)
      if gfa_line[0] == "S"
        gfa_line = gfa_line.to_rgfa_line(vlevel: @vlevel)
      else
        gfa_line = gfa_line.to_rgfa_line(version: :gfa2, vlevel: @vlevel)
      end
    elsif RGFA::Lines::GFA1Specific.include?(gfa_line.class)
      raise RGFA::VersionError,
        "Version: 2.0 (#{@version_explanation})\n"+
        "Cannot add instance of incompatible line type "+
        "(#{gfa_line.class})"
    end
    case gfa_line.record_type
    when :H
      if @vlevel > 0 and gfa_line.VN and gfa_line.VN.to_sym != :"2.0"
        raise RGFA::VersionError,
          "Header line specified wrong version (#{gfa_line.VN})\n"+
          "Line: #{gfa_line}\n"+
          "File version: 2.0 (#{@version_explanation})"
      end
      header.merge(gfa_line)
    when :S
      if gfa_line.version == :gfa1
        raise RGFA::VersionError,
          "Version: 2.0 (#{@version_explanation})\n"+
          "GFA1 segment found: #{gfa_line}"
      end
      gfa_line.connect(self)
    else
      gfa_line.connect(self)
    end
  end

end
