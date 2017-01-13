#
# Methods for the RGFA class, which allow to add redundant junction
# sequences to merged linear paths.
#
# @tested_in XXX
#
module RGFA::GraphOperations::RedundantLinearPaths

  private

  def junction_junction_paths(sn, exclude)
    retval = []
    exclude << sn
    s = segment(sn)
    s.dovetails(:L).each do |dL|
      eL = dL.other_end([s, :L])
      next if exclude.include?(eL.name) or
        eL.segment.dovetails(eL.end_type).size == 1
      retval << [true, eL, [s, :R], true]
    end
    s.dovetails(:R).each do |dR|
      eR = dR.other_end([s, :R])
      next if exclude.include?(eR.name) or
        eR.segment.dovetails(eR.end_type).size == 1
      retval << [true, [s, :R], eR.invert, true]
    end
    return retval
  end

  def extend_linear_path_to_junctions(segpath)
    segpath[0] = segpath[0].to_segment_end
    segfirst = segment(segpath[0].segment)
    segfirst_d = segfirst.dovetails(segpath[0].end_type.invert)
    redundant_first = (segfirst_d.size > 0)
    if segfirst_d.size == 1
      segpath.unshift(segfirst_d[0].other_end(segpath[0].invert))
    end
    segpath.unshift(redundant_first)
    segpath[-1] = segpath[-1].to_segment_end
    seglast = segment(segpath[-1].segment)
    seglast_d = seglast.dovetails(segpath[-1].end_type)
    redundant_last = (seglast_d.size > 0)
    if seglast_d.size == 1
      segpath << seglast_d[0].other_end(segpath[-1]).invert
    end
    segpath << redundant_last
  end

  def link_duplicated_first(merged, first, reversed, jntag)
    # annotate junction
    jntag ||= :jn
    if !first.get(jntag)
      first.set(jntag, {"L" => [], "R" => []})
    end
    if reversed
      first.get(jntag)["L"] << [merged.name, "-"]
    else
      first.get(jntag)["R"] << [merged.name, "+"]
    end
    # create temporary link
    len = first.sequence.size
    if version == :gfa1
      self << RGFA::Line::Edge::Link.new([first.name.to_s,
                                          reversed ? "-" : "+",
                                          merged.name.to_s,"+",
                                          "#{len}M", "co:Z:temporary"])
    elsif version == :gfa2
      self << RGFA::Line::Edge::GFA2.new(["*",first.name.to_s+
                                          (reversed ? '-' : '+'),
                                          "#{merged.name}+",
                                          # note: s1 coords are on purpose fake
                                          reversed ? "0" : "#{len-1}",
                                          reversed ? "1" : "#{len}$",
                                          "0", len.to_s,
                                          "#{len}M", "co:Z:temporary"])
    else
      raise RGFA::AssertionError
    end
  end

  def link_duplicated_last(merged, last, reversed, jntag)
    # annotate junction
    jntag ||= :jn
    if !last.get(jntag)
      last.set(jntag, {"L" => [], "R" => []})
    end
    if reversed
      last.get(jntag)["R"] << [merged.name, "-"]
    else
      last.get(jntag)["L"] << [merged.name, "+"]
    end
    # create temporary link
    len = last.sequence.size
    if version == :gfa1
      self << RGFA::Line::Edge::Link.new([merged.name.to_s, "+",
                                          last.name.to_s,
                                          reversed ? "-" : "+",
                                          "#{len}M", "co:Z:temporary"])
    elsif version == :gfa2
      mlen = merged.sequence.size
      self << RGFA::Line::Edge::GFA2.new(["*", "#{merged.name}+",
                                          last.name.to_s+
                                          (reversed ? '-' : '+'),
                                          (mlen - len).to_s, "#{mlen}$",
                                          # note: s2 coords are on purpose fake
                                          reversed ? "#{len - 1}" : "0",
                                          reversed ? "#{len}$" : "1",
                                          "#{len}M", "co:Z:temporary"])
    else
      raise RGFA::AssertionError
    end
  end

  def remove_junctions(jntag)
    jntag ||= :jn
    segments.each do |s|
      jndata = s.get(jntag)
      if jndata
        len = s.sequence.size
        jndata["L"].each do |m1, dir1|
          jndata["R"].each do |m2, dir2|
            if version == :gfa1
              self << RGFA::Line::Edge::Link.new([m1.to_s, dir1.to_s,
                                                  m2.to_s, dir2.to_s,
                                                  "#{len}M"])
            elsif version == :gfa2
              m1len = segment(m1).sequence.size
              m2len = segment(m2).sequence.size
              r1 = dir1.to_sym == :-
              r2 = dir2.to_sym == :-
              self << RGFA::Line::Edge::GFA2.new(["*", "#{m1}#{dir1}",
                                                  "#{m2}#{dir2}",
                                                  r1 ? "0" : "#{m1len - len}",
                                                  r1 ? "#{len}" : "#{m1len}$",
                                                  r2 ? "#{m2len - len}" : "0",
                                                  r2 ? "#{m2len}$" : "#{len}",
                                                  "#{len}M"])
            else
              raise RGFA::AssertionError
            end
          end
        end
        s.disconnect
      end
    end
  end

end
