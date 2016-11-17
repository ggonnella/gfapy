#
# Methods which edit the graph components without traversal
#
module RGFATools::CopyNumber

  # Sets the count tag to use as default by coverage computations
  # <i>(defaults to: +:RC+)</i>.
  #
  # @return [RGFA] self
  # @param tag [Symbol] the tag to use
  def set_default_count_tag(tag)
    @default[:count_tag] = tag
    return self
  end

  # Sets the unit length (k-mer size, average read lenght or average fragment
  # length) to use for coverage computation
  # <i>(defaults to: 1)</i>.
  #
  # @param unit_length [Integer] the unit length to use
  # @return [RGFA] self
  def set_count_unit_length(unit_length)
    @default[:unit_length] = unit_length
    return self
  end

  # Delete segments which have a coverage under a specified value.
  #
  # @param mincov [Integer] the minimum coverage
  # @!macro [new] count_tag
  #   @param count_tag [Symbol] <i>(defaults to: +:RC+ or the value set by
  #     {#set_default_count_tag})</i> the count tag to use for coverage
  #     computation
  # @!macro [new] unit_length
  #   @param unit_length [Integer] <i>(defaults to: 1 or the value set by
  #     {#set_count_unit_length})</i> the unit length to use for coverage
  #     computation
  #
  # @return [RGFA] self
  def delete_low_coverage_segments(mincov,
                                   count_tag: @default[:count_tag],
                                   unit_length: @default[:unit_length])
    segments.each do |s|
      cov = s.coverage(count_tag: count_tag,
                       unit_length: unit_length)
      s.disconnect if cov < mincov
    end
    self
  end

  # @param mincov [Integer] <i>(defaults to: 1/4 of +single_copy_coverage+)</i>
  #   the minimum coverage, cn for segments under this value is set to 0
  # @param single_copy_coverage [Integer]
  #   the coverage that shall be considered to be single copy
  # @param cn_tag [Symbol] <i>(defaults to: +:cn+)</i>
  #   the tag to use for storing the copy number
  # @!macro count_tag
  # @!macro unit_length
  # @return [RGFA] self
  def compute_copy_numbers(single_copy_coverage,
                           mincov: single_copy_coverage * 0.25,
                           count_tag: @default[:count_tag],
                           cn_tag: :cn,
                           unit_length: @default[:unit_length])
    segments.each do |s|
      cov = s.coverage!(count_tag: count_tag, unit_length: unit_length).to_f
      if cov < mincov
        cn = 0
      elsif cov < single_copy_coverage
        cn = 1
      else
        cn = (cov / single_copy_coverage).round
      end
      s.set(cn_tag, cn)
    end
    self
  end

  # Applies the computed copy number to a segment
  # @!macro [new] apply_copy_number
  #   @return [RGFA] self
  #   @param [:lowcase, :upcase, :number, :copy] copy_names_suffix
  #     <i>(Defaults to: +:lowcase+)</i>
  #     Symbol representing a system to compute the names from the name of
  #     the original segment. See "Automatic computation of the copy names"
  #     in #multiply_extended.
  #   @param count_tag [Symbol] tag to use for storing the copy number
  #     (default: cn)
  #   @param distribute [Symbol] distribution policy, see #multiply_extended
  #   @param origin_tag [Symbol] tag to use for storing the origin (default: or)
  #   @param conserve_components [Boolean] when factor is 0,
  #     do not remove segments if doing so increases the number of components
  #     in the graph (default: true)
  # @param segment [RGFA::Line::Segment, Symbol] segment or segment name
  def apply_copy_number(segment, count_tag: :cn,
                        distribute: :auto,
                        copy_names_suffix: :lowcase, origin_tag: :or,
                        conserve_components: true)
    s, sn = segment_and_segment_name(segment)
    factor = s.get!(count_tag)
    multiply_extended(sn, factor,
             distribute: distribute,
             copy_names: copy_names_suffix,
             conserve_components: conserve_components,
             origin_tag: origin_tag)
    self
  end

  # Applies the computed copy number to all segments
  # @!macro apply_copy_number
  def apply_copy_numbers(count_tag: :cn, distribute: :auto,
                         copy_names_suffix: :lowcase, origin_tag: :or,
                         conserve_components: true)
    segments.sort_by{|s|s.get!(count_tag)}.each do |s|
      multiply_extended(s.name, s.get(count_tag),
               distribute: distribute,
               copy_names: copy_names_suffix,
               conserve_components: conserve_components,
               origin_tag: origin_tag)
    end
    self
  end

end
