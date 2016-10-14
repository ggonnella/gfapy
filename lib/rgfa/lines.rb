require_relative "error"
require_relative "comments"
require_relative "headers"
require_relative "segments"
require_relative "links"
require_relative "containments"
require_relative "custom_records"
require_relative "paths"
require_relative "fragments"
require_relative "ordered_groups"
require_relative "unordered_groups"
require_relative "gaps"
require_relative "edges"

#
# Methods for the RGFA class, which allow to handle lines of multiple types.
#
module RGFA::Lines

  include RGFA::Comments
  include RGFA::Headers
  include RGFA::Segments
  include RGFA::Links
  include RGFA::Containments
  include RGFA::CustomRecords
  include RGFA::Paths
  include RGFA::Fragments
  include RGFA::Gaps
  include RGFA::Edges
  include RGFA::UnorderedGroups
  include RGFA::OrderedGroups

  GFA1Specific = [
                   RGFA::Line::Link,
                   RGFA::Line::Containment,
                   RGFA::Line::Path,
                 ]

  GFA2Specific = [
                   RGFA::Line::CustomRecord,
                   RGFA::Line::Fragment,
                   RGFA::Line::Gap,
                   RGFA::Line::Edge,
                   RGFA::Line::UnorderedGroup,
                   RGFA::Line::OrderedGroup,
                  ]

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
  def <<(gfa_line)
    case version
    when :"1.0"
      add_line_GFA1(gfa_line)
    when :"2.0"
      add_line_GFA2(gfa_line)
    when nil
      add_line_unknown_version(gfa_line)
    else
      raise # This point should never be reached
    end
    return self
  end

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
      add_comment(gfa_line)
    when :H
      gfa_line = gfa_line.to_rgfa_line(validate: @validate)
      add_header(gfa_line)
      if gfa_line.VN
        @version = gfa_line.VN.to_sym
        @version_explanation = "specified in header VN tag"
        validate_version!
        @line_queue.size.times {self << @line_queue.shift}
      end
    when :S
      gfa_line = gfa_line.to_rgfa_line(validate: @validate)
      @version = gfa_line.version
      @version_explanation = "implied by: syntax of S #{gfa_line.name} line"
      process_line_queue
      add_segment(gfa_line)
    when :E, :F, :G, :U, :O
      @version = :"2.0"
      @version_explanation = "implied by: presence of a #{rt} line"
      process_line_queue
      self << gfa_line
    when :L, :C, :P
      @version_guess = :"1.0"
      @line_queue << gfa_line
    else
      @line_queue << gfa_line
    end
  end
  private :add_line_unknown_version

  def add_line_GFA1(gfa_line)
    if gfa_line.kind_of?(String)
      gfa_line = gfa_line.to_rgfa_line(version: :"1.0", validate: @validate)
    elsif RGFA::Lines::GFA2Specific.include?(gfa_line.class)
      raise RGFA::VersionError,
        "Version: 1.0 (#{@version_explanation})\t"+
        "Cannot add instance of incompatible line type (#{rt})"
    end
    case gfa_line.record_type
    when :"#"
      add_comment(gfa_line)
    when :H
      if gfa_line.VN and gfa_line.VN.to_sym != :"1.0"
        raise RGFA::VersionError,
          "Header line specified wrong version (#{gfa_line.VN})\n"+
          "Line: #{gfa_line}\n"+
          "File version: 1.0 (#{@version_explanation})"
      end
      add_header(gfa_line)
    when :S
      add_segment(gfa_line)
    when :L
      add_link(gfa_line)
    when :C
      add_containment(gfa_line)
    when :P
      add_path(gfa_line)
    else
      raise RGFA::TypeError,
        "Invalid record type #{rt}" # should be unreachable
    end
  end
  private :add_line_GFA1

  def add_line_GFA2(gfa_line)
    if gfa_line.kind_of?(String)
      gfa_line = gfa_line.to_rgfa_line(version: :"2.0", validate: @validate)
    elsif RGFA::Lines::GFA1Specific.include?(gfa_line.class)
      raise RGFA::VersionError,
        "Version: 2.0 (#{@version_explanation})\t"+
        "Cannot add instance of incompatible line type (#{rt})"
    end
    case gfa_line.record_type
    when :"#"
      add_comment(gfa_line)
    when :H
      if gfa_line.VN and gfa_line.VN.to_sym != :"2.0"
        raise RGFA::VersionError,
          "Header line specified wrong version (#{gfa_line.VN})\n"+
          "Line: #{gfa_line}\n"+
          "File version: 2.0 (#{@version_explanation})"
      end
      add_header(gfa_line)
    when :S
      add_segment(gfa_line)
    when :E
      add_edge(gfa_line)
    when :G
      add_gap(gfa_line)
    when :F
      add_fragment(gfa_line)
    when :U
      add_unordered_group(gfa_line)
    when :O
      add_ordered_group(gfa_line)
    else
      add_custom_record(gfa_line)
    end
  end
  private :add_line_GFA2

  def process_line_queue
    if @version.nil?
      @version = @version_guess
    end
    @line_queue.size.times {self << @line_queue.shift}
  end

  # Delete elements from the RGFA graph
  # @overload rm(segment)
  #   @param segment [String, RGFA::Line::Segment] segment name or instance
  # @overload rm(path)
  #   @param path [String, RGFA::Line::Segment] path name or instance
  # @overload rm(link)
  #   @param link [RGFA::Line::Link] link line instance
  # @overload rm(containment)
  #   @param containment [RGFA::Line::Containment] containment line instance
  # @overload rm(comment)
  #   @param comment [RGFA::Line::Comment] comment line instance
  # @overload rm(custom_record)
  #   @param custom_record [RGFA::Line::CustomRecord] custom record instance
  # @overload rm(:headers)
  #   Remove all headers
  # @overload rm(array)
  #   Calls {#rm} using each element of the array as argument
  #   @param array [Array]
  # @overload rm(method_name, *args)
  #   Call a method of RGFA instance, then {#rm} for each returned value
  #   @param method_name [Symbol] method to call
  #   @param args arguments of the method
  # @return [RGFA] self
  def rm(x, *args)
    if x.kind_of?(RGFA::Line)
      raise RGFA::ArgumentError,
        "One argument required if first RGFA::Line" if !args.empty?
      case x.record_type
      when :H then raise RGFA::ArgumentError,
                           "Cannot remove single header lines"
      when :S then delete_segment(x)
      when :P then delete_path(x)
      when :L then delete_link(x)
      when :C then delete_containment(x)
      when :"#" then delete_comment(x)
      else delete_custom_record(x)
      end
    elsif x.kind_of?(Symbol)
      if @segments.has_key?(x)
        if !args.empty?
          raise RGFA::ArgumentError,
            "One arguments required if first segment name"
        end
        delete_segment(x)
      elsif @paths.has_key?(x)
        if !args.empty?
          raise RGFA::ArgumentError, "One argument required if first path name"
        end
        delete_path(x)
      elsif x == :headers
        if !args.empty?
          raise RGFA::ArgumentError, "One argument required if first :headers"
        end
        delete_headers
      elsif x == :comments
        if !args.empty?
          raise RGFA::ArgumentError, "One argument required if first :comments"
        end
        delete_comments
      else
        if respond_to?(x)
          rm(send(x, *args))
        else
          raise RGFA::ArgumentError, "Cannot remove #{x.inspect}"
        end
      end
    elsif x.kind_of?(String)
      rm(x.to_sym, *args)
    elsif x.kind_of?(Array)
      x.each {|elem| rm(elem, *args)}
    elsif x.nil?
      return self
    else
      raise RGFA::ArgumentError, "Cannot remove #{x.inspect}"
    end
    return self
  end

  # Rename a segment or a path
  #
  # @param old_name [String] the name of the segment or path to rename
  # @param new_name [String] the new name for the segment or path
  #
  # @raise[RGFA::NotUniqueError]
  #   if +new_name+ is already a segment or path name
  # @return [RGFA] self
  def rename(old_name, new_name)
    old_name = old_name.to_sym
    new_name = new_name.to_sym
    s = segment(old_name)
    pt = nil
    if s.nil?
      pt = path(old_name)
      if pt.nil?
        raise RGFA::NotFoundError,
          "#{old_name} is not a path or segment name"
      end
    end
    if segment(new_name) or path(new_name)
      raise RGFA::NotUniqueError,
        "#{new_name} is already a path or segment name"
    end
    if s
      s.name = new_name
      @segments.delete(old_name)
      @segments[new_name] = s
    else
      pt.path_name = new_name
      @paths.delete(old_name)
      @paths[new_name] = pt
    end
    self
  end

  private

  def lines
    comments + headers + segments + links +
      containments + paths + custom_records.values
  end

  def each_line(&block)
    lines.each(&block)
  end

end
