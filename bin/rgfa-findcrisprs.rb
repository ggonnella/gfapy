#!/usr/bin/env ruby

require "rgfatools"

# crisprs have a structure ARU1RU..RUnRB where |U|~|R| in [24..50]

$debugmode = false
$spacersonly = false

class RGFA

  def find_crisprs(minrepeats=3,minlen=24,maxlen=50)
    ls = {}
    segment_names.each do |sn|
      s = segment(sn)
      s.cn = (s.coverage(unit_length: @default[:unit_length],
                         count_tag: @default[:count_tag])/2).round
    end
    output_segment_infos if $debugmode
    maxvisits_global = {:B => {}, :E => {}}
    segment_names.each do |sn|
      s = segment(sn)
      next if s.length < minlen or s.length > maxlen
      next if s.cn < minrepeats
      circles = {}
      linear = {}
      maxvisits = {}
      [:B, :E].each do |rt|
        maxvisits[rt] = maxvisits_global[rt].dup
        maxvisits[rt][sn] ||= s.cn
        circles[rt] = []
        linear[rt] = []
        segment_end = [s, rt].to_segment_end
        links_of(segment_end).each do |l|
          search_circle(segment_end.invert_end_type,
                        segment_end,
                        l,
                        maxvisits[rt],0,
                        minlen,
                        maxlen*2+s.length,
                        [segment_end],
                        circles[rt],
                        linear[rt])
        end
        if maxvisits[rt][sn.to_sym] > 0
          multi = {:l => [], :c => []}
          [[linear[rt],:l], [circles[rt],:c]].each do |paths, pt|
            paths.each do |c|
              min_mv = s.cn
              upto = (pt == :l ? -1 : -2)
              c[0..upto].each do |csn, et|
                mv = maxvisits[rt][csn.to_sym]
                if mv < min_mv
                  min_mv = mv
                end
              end
              if min_mv > 0
                min_mv.times { multi[pt] << c.dup }
                c[0..upto].each do |csn, et|
                  maxvisits[rt][csn.to_sym] -= min_mv
                end
              end
            end
          end
          circles[rt] += multi[:c]
          linear[rt] += multi[:l]
        end
      end
      n_paths = (circles[:E].size+circles[:B].size+
                 linear[:E].size+linear[:B].size)
      if (circles[:E].size - circles[:B].size).abs > 1
        next
      end
      if (linear[:E].size - linear[:B].size).abs > 0
        next
      end
      if linear[:E].size != 1
        next
      end
      merged_circles = []
      circles[:E].each {|c|merged_circles << merge_crisprs_path(c,s,:E)}
      before = merge_crisprs_path(linear[:B].first,s,:B)
      after = merge_crisprs_path(linear[:E].first,s,:E)
      next if merged_circles.size < minrepeats
      maxvisits_global = maxvisits
      instances = 1
      possible_instances = 0
      merged_circles.each do |seq|
        if seq.length > s.length + minlen
          possible_instances += 1
        end
        instances += 1
      end
      if $spacersonly
        puts merged_circles.sort.map(&:upcase)
      else
        puts "CRISP signature found in segment #{s.name}"
        puts
        puts "  Before: sequence = ...#{before[-50..-1]}"
        puts
        if possible_instances > 0
          instances = "#{instances}..#{instances+possible_instances}"
        end
        puts "  Repeat: instances = #{instances}; "+
        "length = #{s.length};\t"+
        "sequence = #{s.sequence}"
        puts
        puts "  Spacers:"
        asterisk = false
        merged_circles.each_with_index do |seq, i|
          if seq.length > s.length + minlen
            str = "=#{s.length}+2*#{(seq.length.to_f - s.length)/2}"
            asterisk = true
            this_asterisk = true
          else
            str = ""
            this_asterisk = false
          end
          puts "    (#{i+1}#{this_asterisk ? "*" : ""})\t"+
            "length = #{seq.length}#{str};\tsequence = #{seq}"
        end
        if asterisk
          puts
          puts "    * = possibly containing inexact repeat instance"
        end
        puts
        puts "After: sequence = #{after[0..49]}..."
      end
    end
  end

  private

  def output_segment_infos
    segment_names.each do |sn|
      s = segment(sn)
      puts "#{s.name}\t#{s.cn}\t"+
        "#{neighbours([s.name,:B]).map{|nb|segment(nb.segment).cn}.inject(:+)}\t"+
        "#{neighbours([s.name,:E]).map{|nb|segment(nb.segment).cn}.inject(:+)}\t"+
        "#{links_of([s.name,:B]).size}\t"+
        "#{links_of([s.name,:E]).size}\t"+
        "#{s.KC}\t#{s.length}"
    end
  end

  def merge_crisprs_path(segpath, repeat, repeat_end)
    merged = create_merged_segment(segpath, merged_name: :short,
                                 disable_tracking: true)[0]
    sequence = merged.sequence[repeat.
                                 sequence.length..-(1+repeat.sequence.length)]
    sequence = sequence.rc if repeat_end == :B
    return sequence
  end

  def search_circle(goal, from, l, maxvisits, dist, mindist,
                    maxdist, path, circles, linear)
    dest = l.other_end(from)
    dest.segment = segment(dest.segment)
    maxvisits[dest.name] ||= dest.segment.cn
    se = dest.invert_end_type
    if dest == goal
      return if dist < mindist
      new_path = path.dup
      new_path << se
      new_path[0..-2].each {|x| maxvisits[x.name] -= 1}
      circles << new_path
      return
    end
    return if maxvisits[dest.name] == 0
    return if path.any?{|x|x.name==dest.name}
    new_path = path.dup
    new_path << se
    dist += dest.segment.length - l.overlap.first.len
    if dist > maxdist
      new_path = path.dup
      new_path << se
      new_path[0..-1].each {|x| maxvisits[x.name] -= 1}
      linear << new_path
      return
    end
    ls = links_of(se)
    if ls.size == 0
      new_path[0..-1].each {|x| maxvisits[x.name] -= 1}
      linear << new_path
      return
    end
    ls.each do |next_l|
      next_dest = segment(next_l.other_end(se).segment)
      maxvisits[next_dest.name] ||= next_dest.cn
      next if maxvisits[next_dest.name] == 0
      search_circle(goal,se,next_l,maxvisits,dist,mindist,maxdist,new_path,
                    circles,linear)
    end
    return
  end

end

if (ARGV.size == 0)
  STDERR.puts "Usage: #$0 <gfa>"
  exit 1
end
gfa = RGFA.from_file(ARGV[0])
gfa.set_default_count_tag(:KC)
gfa.header.ks ||= gfa.segments[0].length + 1
gfa.set_count_unit_length(gfa.header.ks-1)
gfa.find_crisprs

