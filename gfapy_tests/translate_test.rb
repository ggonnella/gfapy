#!/usr/bin/env ruby

#
# This scripts converts VERY ROUGHLY the tests of RGFA in gfapy Tests
#

filename = ARGV[0]
f = File.new(filename)
puts "import gfapy"
puts "import unittest"
puts
prev_empty = true
klass = nil
before_first = true
f.each do |line|
  line.chomp!
  line.gsub!(/^class Test(.*) < Test::Unit::TestCase/,'class Test\1(unittest.TestCase):')
  line.gsub!("assert_equal","self.assertEqual")
  line.gsub!(/assert_raises?\((.*)\) *(\{|do) *(.+?) *\}?/,
             'with self.assertRaises(\1): \3')
  line.gsub!(/assert_raises?/, "with self.assertRaises")
  line.gsub!("assert_not_equal","self.assertNotEqual")
  line.gsub!("assert_nil","self.assertIsNone")
  line.gsub!("assert_not_nil","self.assertIsNotNone")
  line.gsub!("assert(!","assert(not ")
  line.gsub!(/assert_kind_of *\((.*, *.*)\)/,'assert(isinstance(\2,\1))')
  line.gsub!("str=","s=")
  line.gsub!("str\.","s.")
  line.gsub!(/([^ ]+)\.to_pos/,'gfapy.LastPos(\1)')
  line.gsub!(/([^ ]+)\.to_lastpos/,'gfapy.LastPos(\1)')
  line.gsub!(/assert_nothing_raised { *(.+?) *}/,'\1 # nothing raised')
  line.gsub!('# nothing raised)', ') # nothing raised')
  line.gsub!("assert_nothing_raised do","")
  line.gsub!(/([^ ]+).to_rgfa_line/,'gfapy.Line.from_string(\1)')
  line.gsub!(/([^ ]+).to_rgfa/,'gfapy.Gfa.from_string(\1)')
  line.gsub!(/([^ ]+).map\(\&:to_s\)/,'[str(x) for x in \1]')
  line.gsub!(/([^ ]+).map\(\&:([^ ]+)\)/,'[x.\2() for x in \1]')
  line.gsub!(/([^ ]+).each\(\&:([^ ]+)\)/,'for x in \1: x.\2()')
  line.gsub!(/( *)([^ ].+)\.each \{ *\|(.*)\| *(.*) *\}/,'\1for \3 in \2: \4')
  line.gsub!(/( *)([^ ].+)\.each do *\|(.*)\| *(.*) */,'\1for \3 in \2: \4')
  line.gsub!(/#\{([^}]+)\}/,'"+"{}".format(\1)+"')
  line.gsub!('+""',"")
  line.gsub!('""+',"")
  line.gsub!(/([A-Za-z0-9_]+)\.to_s/,'str(\1)')
  line.gsub!(/def test_([A-Za-z0-9_]+)/,'def test_\1(self):')
  line.gsub!(/([^ ]+).size/,'len(\1)')
  line.gsub!("RGFA.new","gfapy.Gfa()")
  line.gsub!("Gfa()(","Gfa(")
  line.gsub!(".new","")
  line.gsub!(".to_sym","")
  line.gsub!("RGFA::","gfapy.")
  line.gsub!("Line::","line.")
  line.gsub!(/([A-Za-z_0-9]*)::/,'\1.')
  line.gsub!(/([A-Za-z_0-9]*)::/,'\1.')
  line.gsub!("nil","None")
  line.gsub!(/(\w*) => /,'\1:')
  line.gsub!("version: ","version=")
  line.gsub!(/\((\w+): ?/,'(\1=')
  line.gsub!("NoMethodError ","AttributeError")
  line.gsub!("vlevel: ","vlevel=")
  line.gsub!(")(vlevel",",vlevel")
  line.gsub!(")(version",",version")
  line.gsub!(/(\w+)!/,'try_get_\1()')
  line.gsub!(/(\w+)\?/,'is_\1()')
  line.gsub!("()(",'(')
  line.gsub!("true","True")
  line.gsub!("false","False")
  line.gsub!("..-1]",":]")
  line.gsub!("..-2]",":-1]")
  line.gsub!("..0]",":1]")
  line.gsub!("..1]",":2]")
  line.gsub!("..2]",":3]")
  line.gsub!(".first",'[0]')
  line.gsub!(".last",'[-1]')
  line.gsub!(".class",".__class__")
  line.gsub!(/([^A-Za-z0-9_]):"?([A-Za-z0-9+\-=_]+)"?/,'\1"\2"')
  line.gsub!(/^( +)([^ ]+) *<< \(?([^ ]+?) *= *([^ ]+)\)/,
             '\1\3 = \4'+"\n"+'\1\2.append(\3)')
  line.gsub!(/([^ ]+) << ([^ ]+)/,'\1.append(\2)')
  line.gsub!(".dup",".copy()")
  line.gsub!(".clone",".copy()")
  line.gsub!(".disconnect",".disconnect()")
  line.gsub!(/\.validate$/,".validate()")
  line.gsub!(".validate *)",".validate())")
  line.gsub!("Alignment.CIGAR","CIGAR")
  line.gsub!("Alignment.Trace","Trace")
  line.gsub!("Alignment.Placeholder","AlignmentPlaceholder")
  line.gsub!("Edge.Link","edge.Link")
  line.gsub!("Edge.Containment","edge.Containment")
  line.gsub!("Edge.GFA2","edge.GFA2")
  line.gsub!("Segment.GFA1","segment.GFA1")
  line.gsub!("Segment.GFA2","segment.GFA2")
  line.gsub!(/ *([^=]+)\.join\(([^\)]*)\)/,'\2.join(\1)')
  line.gsub!(/OL\[([^,]*),([^\]]*)\]/,'gfapy.OrientedLine(\1,\2)')
  if line =~ /^class Test/
    line.gsub!(".","")
    line.gsub!("unittestTestCase","unittest.TestCase")
    line =~ /class (\w+)/
    klass = $1
  end
  if line =~ /def test/
    before_first = false
  end
  if before_first
    line.gsub!("@@","")
  elsif klass
    line.gsub!("@@","#{klass}.")
  end
  if line !~ /^ *end *$/ and line !~ /require/ and line !~ /Module/ and \
      (!prev_empty or !line.strip.empty?)
    puts line
    prev_empty = line.strip.empty?
  end
end
