require_relative "error"

#
# Methods for the RGFA class, which allow to handle lines of multiple types.
#
module RGFA::Lines

  # Add a line to a RGFA
  #
  # @overload <<(gfa_line_string)
  #   @param [String] gfa_line_string representation of a RGFA line
  # @overload <<(gfa_line)
  #   @param [RGFA::Line] gfa_line instance of a subclass of RGFA::Line
  # @raise [RGFA::DuplicatedLabelError] if multiple segment or path lines
  #   with the same name are added
  # @return [RGFA] self
  def <<(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    rt = gfa_line.record_type
    case rt
    when :H
      add_header(gfa_line)
    when :S
      add_segment(gfa_line)
    when :L
      add_link(gfa_line)
    when :C
      add_containment(gfa_line)
    when :P
      add_path(gfa_line)
    when :"#"
      add_comment(gfa_line)
    else
      add_custom_record(gfa_line)
    end
    return self
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
      raise ArgumentError,
        "One argument required if first RGFA::Line" if !args.empty?
      case x.record_type
      when :H then raise ArgumentError, "Cannot remove single header lines"
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
          raise ArgumentError, "One arguments required if first segment name"
        end
        delete_segment(x)
      elsif @paths.has_key?(x)
        if !args.empty?
          raise ArgumentError, "One argument required if first path name"
        end
        delete_path(x)
      elsif x == :headers
        if !args.empty?
          raise ArgumentError, "One argument required if first :headers"
        end
        delete_headers
      elsif x == :comments
        if !args.empty?
          raise ArgumentError, "One argument required if first :comments"
        end
        delete_comments
      else
        if respond_to?(x)
          rm(send(x, *args))
        else
          raise ArgumentError, "Cannot remove #{x.inspect}"
        end
      end
    elsif x.kind_of?(String)
      rm(x.to_sym, *args)
    elsif x.kind_of?(Array)
      x.each {|elem| rm(elem, *args)}
    elsif x.nil?
      return self
    else
      raise ArgumentError, "Cannot remove #{x.inspect}"
    end
    return self
  end

  # Rename a segment or a path
  #
  # @param old_name [String] the name of the segment or path to rename
  # @param new_name [String] the new name for the segment or path
  #
  # @raise[RGFA::DuplicatedLabelError]
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
        raise RGFA::LineMissingError,
          "#{old_name} is not a path or segment name"
      end
    end
    if segment(new_name) or path(new_name)
      raise RGFA::DuplicatedLabelError,
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

# Exception raised if a label for segment or path is duplicated
class RGFA::DuplicatedLabelError < RGFA::Error; end

# The error raised by banged line finders if no line respecting the criteria
# exist in the RGFA
class RGFA::LineMissingError < RGFA::Error; end
