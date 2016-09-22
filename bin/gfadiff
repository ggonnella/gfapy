#!/usr/bin/env ruby

require "rgfa"

rt = []
all_rt = %W[-h -s -l -c -p]
all_rt.each do |rtopt|
  rt << ARGV.delete(rtopt)
end
rt.compact!
rt = all_rt if rt.empty?

out_identical = ARGV.delete("-i")

out_script = ARGV.delete("-script")

if ARGV.size != 2
  STDERR.puts "Compare two RGFA files"
  STDERR.puts
  STDERR.puts "Usage: #$0 [-h] [-s] [-l] [-c] [-p] [-i] [-script] <gfa1> <gfa2>"
  STDERR.puts
  STDERR.puts "If a combination of -h,-s,-l,-c and/or -p is specified, then"
  STDERR.puts "only record of the specified type [h=headers, s=segments, "
  STDERR.puts "l=links, c=containments, p=paths] are compared. "
  STDERR.puts "(default: -h -s -l -c -p)"
  STDERR.puts
  STDERR.puts "Other options:"
  STDERR.puts "  -i: output msg if identical"
  STDERR.puts "  -script: create ruby script to transform gfa1 in gfa2"
  exit 1
end

if out_script
  puts "#!/usr/bin/env ruby"
  puts
  puts "#"
  puts "# This script was automatically generated using gfadiff.rb"
  puts "#"
  puts "# Purpose: edit gfa1 into gfa2"
  puts "#"
  puts "# gfa1: #{ARGV[0]}"
  puts "# gfa2: #{ARGV[1]}"
  puts "#"
  puts
  puts "require \"rgfa\""
  puts
  puts "gfa = RGFA.from_file(\"#{ARGV[0]}\")"
  puts
end

gfa1 = RGFA.new
gfa1.turn_off_validations
gfa1.read_file(ARGV[0])
gfa2 = RGFA.new
gfa2.turn_off_validations
gfa2.read_file(ARGV[1])

if rt.include?("-h")
  h1 = gfa1.header
  h2 = gfa2.header
  if h1 == h2
    if out_identical
      puts "# Header values are identical"
    elsif out_script
      puts "# Headers"
      puts "# ... are identical"
      puts
    end
  else
    if out_script
      puts "# Headers"
      puts
    end
    (h1.optional_fieldnames - h2.optional_fieldnames).each do |k|
      if out_script
        puts "gfa.header.delete_field(#{k.inspect})"
      else
        v = h1.get(k)
        if v.kind_of?(RGFA::FieldArray)
          t = v.datatype
          v.each do |elem|
            elem = elem.to_gfa_field(datatype: t)
            puts "<\t[headers/exclusive/multivalue/#{k}]\t#{elem}"
          end
        else
          v = h1.field_to_s(k, optfield: true)
          puts "M\t[headers/exclusive]\t#{k.inspect}\t#{v}"
        end
      end
    end
    (h2.optional_fieldnames - h1.optional_fieldnames).each do |k|
      v = h2.get(k)
      if out_script
        t = h2.get_datatype(k)
        puts "gfa.header.set_datatype(#{k.inspect}, #{t.inspect})"
        if v.kind_of?(RGFA::FieldArray)
          t = v.datatype
          v.each do |elem|
            puts "gfa.header.add(#{k.inspect}, #{elem.inspect}, "+
                 "#{t.inspect})"
          end
        else
          puts "gfa.header.#{k}=#{v.inspect}"
        end
      else
        if v.kind_of?(RGFA::FieldArray)
          t = v.datatype
          v.each do |elem|
            elem = elem.to_gfa_field(datatype: t)
            puts ">\t[headers/exclusive/multivalue/#{k}]\t#{elem}"
          end
        else
          v = h2.field_to_s(k, optfield: true)
          puts ">\t[headers/exclusive]\t#{k.inspect}\t#{v}"
        end
      end
    end
    (h1.optional_fieldnames & h2.optional_fieldnames).each do |k|
      v1 = h1.get(k)
      v2 = h2.get(k)
      v1a = v1.kind_of?(RGFA::FieldArray) ? v1.sort : [v1]
      v2a = v2.kind_of?(RGFA::FieldArray) ? v2.sort : [v2]
      t1 = v1.kind_of?(RGFA::FieldArray) ? v1.datatype : h1.get_datatype(k)
      t2 = v2.kind_of?(RGFA::FieldArray) ? v2.datatype : h2.get_datatype(k)
      m1 = v1.kind_of?(RGFA::FieldArray) ? "multivalue/" : ""
      m2 = v2.kind_of?(RGFA::FieldArray) ? "multivalue/" : ""
      if out_script
        if t1 != t2 or v1a != v2a
          puts "gfa.header.delete(#{k.inspect})"
          v2a.each do |v2|
            v2 = v2.to_gfa_field(datatype: t2)
            puts "gfa.header.add(#{k.inspect}, #{v2.inspect}, "+
                 "#{t2.inspect})"
          end
        end
      else
        if t1 != t2
          v1a.each do |v1|
            v1 = v1.to_gfa_field(datatype: t1)
            puts "<\t[headers/typediff/#{m1}#{k}#{}]\t#{v1}"
          end
          v2a.each do |v2|
            v2 = v2.to_gfa_field(datatype: t2)
            puts ">\t[headers/typediff/#{m2}#{k}]\t#{v2}"
          end
        else
          (v1a-v2a).each do |v1|
            v1 = v1.to_gfa_field(datatype: t1)
            puts "<\t[headers/valuediff/#{m1}#{k}]\t#{v1}"
          end
          (v2a-v1a).each do |v2|
            v2 = v2.to_gfa_field(datatype: t2)
            puts ">\t[headers/valuediff/#{m2}#{k}]\t#{v2}"
          end
        end
      end
    end
    if out_script
      puts
    end
  end
end

def diff_segments_or_paths(gfa1,gfa2,rt,out_script,out_identical)
  rts = rt + "s"
  rtsU = rts[0].upcase + rts[1..-1]
  s1names = gfa1.send("#{rt}_names").sort
  s2names = gfa2.send("#{rt}_names").sort
  difffound = false
  if out_script
    puts "# #{rtsU}"
    puts
  end
  (s1names - s2names).each do |sn|
    difffound = true
    segstr = gfa1.send(rt,sn).to_s
    if out_script
      puts "gfa.rm(#{sn.inspect})"
    else
      puts "<\t[#{rts}/exclusive]\t#{segstr}"
    end
  end
  (s2names - s1names).each do |sn|
    difffound = true
    segstr = gfa2.send(rt,sn).to_s
    if out_script
      puts "gfa << #{segstr.inspect}"
    else
      puts ">\t[#{rts}/exclusive]\t#{segstr}"
    end
  end
  (s1names & s2names).each do |sn|
    s1 = gfa1.send(rt,sn)
    s2 = gfa2.send(rt,sn)
    s1.required_fieldnames.each do |fn|
      v1 = s1.field_to_s(fn)
      v2 = s2.field_to_s(fn)
      if v1 != v2
        difffound = true
        if out_script
          puts "gfa.#{rt}(#{sn.inspect}).#{fn}=#{v2.inspect}"
        else
          puts "<\t[#{rts}/reqfields/valuediff/#{sn}]\t#{v1}"
          puts ">\t[#{rts}/reqfields/valuediff/#{sn}]\t#{v2}"
        end
      end
    end
    s1f = s1.optional_fieldnames
    s2f = s2.optional_fieldnames
    (s1f - s2f).each do |fn|
      difffound = true
      if out_script
        puts "gfa.#{rt}(#{sn.inspect}).delete_field(#{fn.inspect})"
      else
        v = s1.field_to_s(fn, optfield: true)
        puts "<\t[#{rts}/optfields/exclusive/#{sn}]\t#{v}"
      end
    end
    (s2f - s1f).each do |fn|
      difffound = true
      if out_script
        v = s2.get(fn)
        t = s2.get_datatype(fn)
        puts "gfa.#{rt}(#{sn.inspect}).set_datatype(#{fn.inspect},#{t})"
        puts "gfa.#{rt}(#{sn.inspect}).#{fn}=#{v.inspect}"
      else
        v = s2.field_to_s(fn, optfield: true)
        puts ">\t[#{rts}/optfields/exclusive/#{sn}]\t#{v}"
      end
    end
    (s1f & s2f).each do |fn|
      v1 = s1.field_to_s(fn, optfield: true)
      v2 = s2.field_to_s(fn, optfield: true)
      if v1 != v2
        difffound = true
        if out_script
          v = s2.get(fn)
          t = s2.get_datatype(fn)
          puts "gfa.#{rt}(#{sn.inspect}).set_datatype(#{fn.inspect},#{t})"
          puts "gfa.#{rt}(#{sn.inspect}).#{fn}=#{v.inspect}"
        else
          puts "<\t[#{rts}/optfields/valuediff/#{sn}]\t#{v1}"
          puts ">\t[#{rts}/optfields/valuediff/#{sn}]\t#{v2}"
        end
      end
    end
  end
  if !difffound
    if out_script
      puts "# ... are identical"
    elsif out_identical
      puts "# #{rtsU} are identical"
    end
  end
  puts if out_script
end

if rt.include?("-s")
  diff_segments_or_paths(gfa1,gfa2, "segment",out_script,out_identical)
end

# TODO: diff of single optfields
if rt.include?("-l")
  difffound = false
  s1names = gfa1.segment_names.sort
  s2names = gfa2.segment_names.sort
  if out_script
    puts "# Links"
    puts
  end
  difflinks1 = []
  (s1names - s2names).each do |sn|
    difffound = true
    [:B, :E].each {|et| difflinks1 += gfa1.links_of([sn, et])}
  end
  difflinks1.uniq.each do |l|
    if !out_script
      puts "<\t[links/exclusive_segments]\t#{l.to_s}"
    end
  end
  difflinks2 = []
  (s2names - s1names).each do |sn|
    difffound = true
    [:B, :E].each {|et| difflinks2 += gfa2.links_of([sn, et])}
  end
  difflinks2.uniq.each do |l|
    if out_script
      puts "gfa << #{l.to_s.inspect}"
    else
      puts ">\t[links/exclusive_segments]\t#{l.to_s}"
    end
  end
  difflinks1b = []
  difflinks2b = []
  (s1names & s2names).each do |sn|
    [:B, :E].each do |et|
      l1 = gfa1.links_of([sn, et])
      l2 = gfa2.links_of([sn, et])
      d1 = l1 - l2
      d2 = l2 - l1
      if !d1.empty?
        difffound = true
        difflinks1b += d1
      end
      if !d2.empty?
        difffound = true
        difflinks2b += d2
      end
    end
  end
  (difflinks1b-difflinks1).uniq.each do |l|
    if out_script
      puts "gfa.rm(gfa.link_from_to(#{l.from.to_sym.inspect}, "+
                                   "#{l.from_orient.inspect}, "+
                                   "#{l.to.to_sym.inspect}, "+
                                   "#{l.to_orient.inspect}, "+
                                   "#{l.overlap.to_s.inspect}.to_cigar))"
    else
      puts "<\t[links/different]\t#{l.to_s}"
    end
  end
  (difflinks2b-difflinks2).uniq.each do |l|
    if out_script
      puts "gfa << #{l.to_s.inspect}"
    else
      puts ">\t[links/different]\t#{l.to_s}"
    end
  end
  if !difffound
    if out_script
      puts "# ... are identical"
    elsif out_identical
      puts "# Links are identical"
    end
  end
  puts if out_script
end

# TODO: this code is similar to -l; make generic and merge
if rt.include?("-c")
  difffound = false
  s1names = gfa1.segment_names.sort
  s2names = gfa2.segment_names.sort
  cexcl1 = []
  (s1names - s2names).each do |sn|
    difffound = true
    cexcl1 += gfa1.contained_in(sn)
    cexcl1 += gfa1.containing(sn)
  end
  cexcl1.uniq.each do |c|
    if !out_script
      puts "<\t[contaiments/exclusive_segments]\t#{c.to_s}"
    end
  end
  cexcl2 = []
  (s2names - s1names).each do |sn|
    difffound = true
    cexcl2 += gfa2.contained_in(sn)
    cexcl2 += gfa2.containing(sn)
  end
  cexcl2.uniq.each do |c|
    if out_script
      puts "gfa << #{c.to_s.inspect}"
    else
      puts ">\t[contaiments/exclusive_segments]\t#{c.to_s}"
    end
  end
  cdiff1 = []
  cdiff2 = []
  (s1names & s2names).each do |sn|
    c1 = gfa1.contained_in(sn)
    c2 = gfa2.contained_in(sn)
    c1 += gfa1.containing(sn)
    c2 += gfa2.containing(sn)
    d1 = c1 - c2
    d2 = c2 - c1
    if !d1.empty?
      difffound = true
      cdiff1 += d1
    end
    if !d2.empty?
      difffound = true
      cdiff2 += d2
    end
  end
  (cdiff1-cexcl1).uniq.each do |l|
    if out_script
      # TODO: handle multiple containments for a segments pair
      puts "gfa.rm(gfa.containment(#{l.from.to_sym.inspect}, "+
                                  "#{l.to.to_sym.inspect}))"
    else
      puts "<\t[containments/different]\t#{l.to_s}"
    end
  end
  (cdiff2-cexcl2).uniq.each do |l|
    if out_script
      puts "gfa << #{l.to_s.inspect}"
    else
      puts ">\t[containments/different]\t#{l.to_s}"
    end
  end
  if !difffound
    if out_script
      puts "# ... are identical"
    elsif out_identical
      puts "# Containments are identical"
    end
  end
  puts if out_script
end

if rt.include?("-p")
  diff_segments_or_paths(gfa1,gfa2,"path",out_script,out_identical)
end

if out_script
  puts
  puts "# Output graph"
  puts "puts gfa"
end
