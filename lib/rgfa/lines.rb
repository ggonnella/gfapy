require_relative "error"

RGFA::Lines = Module.new

require_relative "lines/comments"
require_relative "lines/containments"
require_relative "lines/custom_records"
require_relative "lines/edges"
require_relative "lines/fragments"
require_relative "lines/gaps"
require_relative "lines/headers"
require_relative "lines/links"
require_relative "lines/ordered_groups"
require_relative "lines/paths"
require_relative "lines/segments"
require_relative "lines/unordered_groups"

#
# Methods for the RGFA class, which allow to handle lines of multiple types.
#
module RGFA::Lines

  include RGFA::Lines::Comments
  include RGFA::Lines::Containments
  include RGFA::Lines::CustomRecords
  include RGFA::Lines::Edges
  include RGFA::Lines::Fragments
  include RGFA::Lines::Gaps
  include RGFA::Lines::Headers
  include RGFA::Lines::Links
  include RGFA::Lines::OrderedGroups
  include RGFA::Lines::Paths
  include RGFA::Lines::Segments
  include RGFA::Lines::UnorderedGroups

  GFA1Specific = [
                   RGFA::Line::Edge::Link,
                   RGFA::Line::Edge::Containment,
                   RGFA::Line::Group::Path,
                 ]

  GFA2Specific = [
                   RGFA::Line::CustomRecord,
                   RGFA::Line::Fragment,
                   RGFA::Line::Gap,
                   RGFA::Line::Edge::GFA2,
                   RGFA::Line::Group::Unordered,
                   RGFA::Line::Group::Ordered,
                   RGFA::Line::Unknown,
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
      gfa_line.to_rgfa_line.connect(self)
    when :H
      gfa_line = gfa_line.to_rgfa_line(validate: @validate)
      header.merge(gfa_line)
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
      gfa_line.connect(self)
    when :E, :F, :G, :U, :O
      gfa_line = gfa_line.to_rgfa_line(validate: @validate, version: version)
      @version = :"2.0"
      @version_explanation = "implied by: presence of a #{rt} line"
      process_line_queue
      gfa_line.connect(self)
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
    when :H
      if gfa_line.VN and gfa_line.VN.to_sym != :"1.0"
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
      gfa_line = gfa_line.to_rgfa_line(version: :"2.0", validate: @validate)
    elsif RGFA::Lines::GFA1Specific.include?(gfa_line.class)
      raise RGFA::VersionError,
        "Version: 2.0 (#{@version_explanation})\t"+
        "Cannot add instance of incompatible line type (#{rt})"
    end
    case gfa_line.record_type
    when :H
      if gfa_line.VN and gfa_line.VN.to_sym != :"2.0"
        raise RGFA::VersionError,
          "Header line specified wrong version (#{gfa_line.VN})\n"+
          "Line: #{gfa_line}\n"+
          "File version: 2.0 (#{@version_explanation})"
      end
      gfa_line.connect(self)
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

  # Delete elements from the RGFA graph
  # @overload rm(segment)
  #   @param segment
  #     [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #     segment name or instance
  # @overload rm(path)
  #   @param path [String, Symbol, RGFA::Line::Path]
  #     path name or instance
  # @overload rm(link)
  #   @param link [RGFA::Line::Edge::Link] link line instance
  # @overload rm(containment)
  #   @param containment [RGFA::Line::Edge::Containment] containment line instance
  # @overload rm(comment)
  #   @param comment [RGFA::Line::Comment] comment line instance
  # @overload rm(custom_record)
  #   @param custom_record [RGFA::Line::CustomRecord] custom record instance
  # @overload rm(array)
  #   Calls {#rm} using each element of the array as argument
  #   @param array [Array]
  # @overload rm(method_name, *args)
  #   Call a method of RGFA instance, then {#rm} for each returned value
  #   @param method_name [Symbol] method to call
  #   @param args arguments of the method
  # @return [RGFA] self
  def rm(x, *args)
    case x
    when RGFA::Line
      raise RGFA::ArgumentError,
        "One argument required if first RGFA::Line" if !args.empty?
      case x.record_type
      when :H then raise RGFA::ArgumentError,
                           "Cannot remove single header lines"
      else
        x.disconnect!
      end
    when Symbol, String
      x = x.to_sym
      l = search_by_id(x)
      if l
        if !args.empty?
          raise RGFA::ArgumentError,
            "One arguments required if first argument is an ID"
        end
        l.disconnect!
      else
        if respond_to?(x)
          rm(send(x, *args))
        else
          raise RGFA::ArgumentError, "Cannot remove #{x.inspect}"
        end
      end
    when Array
      x.each {|elem| rm(elem, *args)}
    when nil, RGFA::Placeholder
      return self
    else
      raise RGFA::ArgumentError, "Cannot remove #{x.inspect}"
    end
    return self
  end

  # Rename a segment or a path
  #
  # @param old_name [String, Symbol] the name of the segment or path to rename
  # @param new_name [String, Symbol] the new name for the segment or path
  #
  # @raise[RGFA::NotUniqueError]
  #   if +new_name+ is already a segment or path name
  # @return [RGFA] self
  def rename(old_name, new_name)
    old_name = old_name.to_sym
    new_name = new_name.to_sym
    l = search_by_id(new_name)
    if l
      raise RGFA::NotUniqueError,
        "#{new_name} is not unique\n"+
        "Matching line: #{l}"
    end
    l = search_by_id(old_name)
    if l.nil?
      raise RGFA::NotFoundError,
        "No line has ID '#{old_name}'"
    end
    l.id = new_name
    @records[l.record_type].delete(old_name)
    @records[l.record_type][new_name] = l
    self
  end

  # @api private
  def register_line(gfa_line)
    api_private_check_gfa_line(gfa_line, "register_line")
    case gfa_line.record_type
    when :H
      @records[:H].merge(gfa_line)
    when :S, :P, nil
      @records[gfa_line.record_type][gfa_line.id] = gfa_line
    when :E, :U, :G, :O
      if gfa_line.id.empty?
        @records[gfa_line.record_type][nil] << gfa_line
      else
        @records[gfa_line.record_type][gfa_line.id] = gfa_line
      end
    else
      @records[gfa_line.record_type] ||= []
      @records[gfa_line.record_type] << gfa_line
    end
  end

  # @api private
  def unregister_line(gfa_line)
    api_private_check_gfa_line(gfa_line, "unregister_line")
    case gfa_line.record_type
    when :H
      raise # This should not happen
    when :E, :S, :P, :U, :G, :O
      if gfa_line.id.empty?
        @records[gfa_line.record_type][nil].delete(gfa_line)
      else
        @records[gfa_line.record_type].delete(gfa_line.id)
      end
    else
      @records[gfa_line.record_type].delete(gfa_line)
    end
  end

  # @api private
  def search_duplicate(gfa_line)
    case gfa_line.record_type
    when :L
      search_link(gfa_line.oriented_from,
                  gfa_line.oriented_to, gfa_line.alignment)
    when :E, :S, :P, :U, :G, :O
      return search_by_id(gfa_line.id)
    else
      return nil
    end
  end

  # @api private
  def search_by_id(id)
    if id.kind_of?(RGFA::Placeholder)
      return nil
    end
    id = id.to_sym
    [:E, :S, :P, :U, :G, :O, nil].each do |rt|
      found = @records[rt][id]
      return found if !found.nil?
    end
    return nil
  end

  private

  def api_private_check_gfa_line(gfa_line, callermeth)
    if !gfa_line.kind_of?(RGFA::Line)
      raise RGFA::TypeError,
        "Note: ##{callermeth} is API private, do not call it directly!\n"+
        "Error: line class is #{gfa_line.class} and not RGFA::Line"
    elsif gfa_line.rgfa != self
      raise RGFA::RuntimeError,
        "Note: ##{callermeth} is API private, do not call it directly!\n"+
        "Error: line.rgfa is "+
        "#{gfa_line.rgfa.class}:#{gfa_line.rgfa.object_id} and not "+
        "RGFA:#{self.object_id}"
    end
  end

  def lines
    comments + headers + segments +
      links + containments + edges +
        paths + ordered_groups + unordered_groups +
          gaps + fragments + custom_records.values
  end

  def each_line(&block)
    lines.each(&block)
  end

end
