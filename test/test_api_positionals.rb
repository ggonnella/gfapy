require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Positionals < Test::Unit::TestCase

  @@s = {
    :S1 => "S\t1\t*",
    :L  => "L\t1\t+\t2\t+\t*",
    :C  => "C\t1\t+\t2\t+\t10\t*",
    :P  => "P\tx\t1+,2+\t*",
    :S2 => "S\t2\t100\t*",
    :E  => "E\t*\t1+\t2+\t10\t20\t30\t40\t*",
    :F  => "F\t1\t5+\t11\t21\t31\t41\t*",
    :G  => "G\t*\t1+\t2+\t1000\t1",
    :U  => "U\t*\t1 2 3",
    :O  => "O\t*\t1+ 2+ 3+",
  }
  @@f = Hash[@@s.map{|k,v|[k,v.split("\t")]}]
  @@l = Hash[@@s.map{|k,v|[k,v.to_rgfa_line]}]

  @@fieldnames = {
    :S1 => [:name, :sequence],
    :L  => [:from_segment, :from_orient, :to_segment, :to_orient, :overlap],
    :C  => [:from_segment, :from_orient, :to_segment, :to_orient, :pos, :overlap],
    :P  => [:path_name, :segment_names, :overlaps],
    :S2 => [:sid, :slen, :sequence],
    :E  => [:eid, :sid1, :sid2, :beg1, :end1, :beg2, :end2, :alignment],
    :F  => [:sid, :external, :s_beg, :s_end, :f_beg, :f_end, :alignment],
    :G  => [:gid, :sid1, :sid2, :disp, :var],
    :U  => [:pid, :items],
    :O  => [:pid, :items],
  }

  # alternative values to set tests
  @@v1 = {
    :S1 => {:name => :sx, :sequence => "accg"},
    :L => {:from_segment => :a1, :from_orient => :-, :to_segment => :a2, :to_orient => :-,
           :overlap => "12M".to_alignment},
    :C => {:from_segment => :cx, :from_orient => :-, :to_segment => :cy, :to_orient => :-,
           :pos => 123, :overlap => "120M".to_alignment},
    :P => {:path_name => :px, :segment_names => [OL[:x,:+], OL[:y,:-]],
           :overlaps => ["10M".to_alignment]},
    :S2 => {:sid => :s2s, :slen => 999, :sequence => "gggg"},
    :E  => {:eid => :e2e, :sid1 => OL[:s2s,:-],
            :sid2 => OL[:t2t,:-],
            :beg1 => 0, :end1 => "100$".to_pos,
            :beg2 => 10, :end2 => "110$".to_pos,
            :alignment => "10M1I10M1D80M".to_alignment},
    :F  => {:sid => :s2s, :external => OL[:ex2ex,:-],
            :s_beg => 0, :s_end => "100$".to_pos,
            :f_beg => 10, :f_end => "110$".to_pos,
            :alignment => "10M1I10M1D80M".to_alignment},
    :G  => {:gid => :g2g, :sid1 => OL[:s2s,:+], :sid2 => OL[:t2t,:-],
            :disp => 2000, :var => 100},
    :O  => {:pid => :O100, :items => [OL[:x1,:+],
                                      OL[:x2,:+],
                                      OL[:x3,:-]]},
    :U  => {:pid => :U100, :items => [:x1, :x2, :x3]},
  }
  @@v2 = {
    :S1 => {:name => :xs, :sequence => "aggc"},
    :L => {:from_segment => :a5, :from_orient => :+, :to_segment => :a7, :to_orient => :+,
           :overlap => "9M3I3M".to_alignment},
    :C => {:from_segment => :cp, :from_orient => :+, :to_segment => :cl, :to_orient => :+,
           :pos => 213, :overlap => "110M4D10M".to_alignment},
    :P => {:path_name => :pu, :segment_names => [OL[:k,:-],
           OL[:l,:+]], :overlaps => ["11M".to_alignment]},
    :S2 => {:sid => :s4s, :slen => 1999, :sequence => "aaaa"},
    :E  => {:eid => :e4e, :sid1 => OL[:s4s,:+],
            :sid2 => OL[:t4t,:+],
            :beg1 => 10, :end1 => "110$".to_pos,
            :beg2 => 0, :end2 => "100$".to_pos,
            :alignment => "10M1I20M1D80M".to_alignment},
    :F  => {:sid => :s4s, :external => OL[:ex4ex, :+],
            :s_beg => 10, :s_end => "110$".to_pos,
            :f_beg => 0, :f_end => "100$".to_pos,
            :alignment => "10M1I20M1D80M".to_alignment},
    :G  => {:gid => :g4g, :sid1 => OL[:s4s,:-], :sid2 => OL[:t4t,:+],
            :disp => 3000, :var => 200},
    :O  => {:pid => :O200, :items => [OL[:x7,:-],
                                      OL[:x6,:+],
                                      OL[:x3,:+]]},
    :U  => {:pid => :U200, :items => [:x6, :x7, :x4]},
  }
  @@aliases = {
      :S1 => {:name => :sid}, :P => {:path_name => :name},
      :S2 => {:sid => :name}, :E => {:eid => :name}, :G => {:gid => :name},
      :U => {:pid => :name}, :O => {:pid => :name},
      :L => {:from_segment => :from, :to_segment => :to},
      :C => {:from_segment => :container, :from_orient => :container_orient,
             :to_segment => :contained, :to_orient => :contained_orient}
  }

  def test_number_of_positionals
    @@f.each do |rt, fields|
      assert_nothing_raised           { fields.to_rgfa_line }
      too_less = fields.clone; too_less.pop
      assert_raise(RGFA::FormatError) { too_less.to_rgfa_line }
      too_many = fields.clone; too_many << "*"
      assert_raise(RGFA::FormatError) { too_many.to_rgfa_line }
    end
  end

  def test_positional_fieldnames
    @@l.each do |rt, line|
      assert_equal(@@fieldnames[rt], line.positional_fieldnames)
    end
  end

  def test_field_getters_and_setters
    @@fieldnames.each do |rt, fn_list|
      fn_list.each_with_index do |fn, i|
        i+=1 # skip record_type
        # field_to_s()
        assert_equal(@@f[rt][i], @@l[rt].field_to_s(fn))
        # validate_field/validate
        assert_nothing_raised { @@l[rt].validate_field(fn) }
        assert_nothing_raised { @@l[rt].validate }
        # fieldname() == get(fieldname)
        assert_equal(@@l[rt].send(fn), @@l[rt].get(fn))
        # fieldname=() and fieldname()
        l = @@l[rt].clone
        l.send("#{fn}=", @@v1[rt][fn])
        assert_equal(@@v1[rt][fn], l.send(fn))
        # set() and get()
        l.set(fn, @@v2[rt][fn])
        assert_equal(@@v2[rt][fn], l.get(fn))
      end
    end
  end

  def test_aliases
    @@aliases.each do |rt, aliasmap|
      aliasmap.each do |orig, al|
        # get(orig) == get(alias)
        assert_equal(@@l[rt].send(orig), @@l[rt].send(al))
        assert_equal(@@l[rt].get(orig),  @@l[rt].get(al))
        # validate_field/validate
        assert_nothing_raised { @@l[rt].validate_field(al) }
        assert_nothing_raised { @@l[rt].validate }
        # field_to_s(orig) == field_to_s(alias)
        assert_equal(@@l[rt].field_to_s(orig), @@l[rt].field_to_s(al))
        # set(al, value) + get(orig)
        l = @@l[rt].clone
        assert_not_equal(@@v1[rt][orig], l.send(orig))
        l.set(al, @@v1[rt][orig])
        assert_equal(@@v1[rt][orig], l.send(orig))
        # alias=value + orig()
        assert_not_equal(@@v2[rt][orig], l.send(orig))
        l.send(:"#{al}=", @@v2[rt][orig])
        assert_equal(@@v2[rt][orig], l.send(orig))
        # set(orig, value) + get(alias)
        assert_not_equal(@@v1[rt][orig], l.send(al))
        l.set(orig, @@v1[rt][orig])
        assert_equal(@@v1[rt][orig], l.send(al))
        # orig=value + alias()
        assert_not_equal(@@v2[rt][orig], l.send(al))
        l.send(:"#{orig}=", @@v2[rt][orig])
        assert_equal(@@v2[rt][orig], l.send(al))
      end
    end
  end

  def test_array_fields
    assert_kind_of(Array, @@l[:P].segment_names)
    assert_kind_of(RGFA::OrientedLine, @@l[:P].segment_names.first)
    assert_kind_of(Array, @@l[:P].overlaps)
    assert_kind_of(RGFA::Alignment::Placeholder, @@l[:P].overlaps.first)
    assert_kind_of(Array, @@l[:O].items)
    assert_kind_of(RGFA::OrientedLine, @@l[:O].items.first)
    assert_kind_of(Array, @@l[:U].items)
    assert_kind_of(Symbol, @@l[:U].items.first)
  end

  def test_orientation
    # orientation is symbol
    assert_equal(:+, @@l[:L].from_orient)
    assert_equal(:+, @@l[:L].to_orient)
    # invert
    assert_equal(:-, @@l[:L].to_orient.invert)
    assert_equal(:+, :-.invert)
    assert_equal(:-, :+.invert)
    # string representation
    assert_equal("+", @@l[:L].field_to_s(:from_orient))
    # invert does not work with string representation
    assert_raise(NoMethodError) {"+".invert}
    # assigning the string representation
    l = @@l[:L].clone
    l.from_orient = "+"
    assert_equal(:+, l.from_orient)
    assert_equal(:-, l.from_orient.invert)
    # non :+/:- symbols is an error
    assert_raises(RGFA::FormatError) {l.from_orient = :x; l.validate}
    # only :+/:- and their string representations are accepted
    assert_raises(RGFA::FormatError) {l.from_orient = "x"; l.validate}
    assert_raises(RGFA::FormatError) {l.from_orient = 1; l.validate}
  end

  def test_oriented_segment
    os = @@l[:P].segment_names.first
    # getter methods
    assert_equal(:"1", os.line)
    assert_equal(:+, os.orient)
    # invert
    assert_equal(:"1", os.invert.line)
    assert_equal(:-, os.invert.orient)
    assert_equal(:-, os.orient.invert)
    # setter methods
    os.line = :"one"
    os.orient = :-
    assert_equal(:"one", os.line)
    assert_equal(:-, os.orient)
    # name
    assert_equal(:"one", os.name)
    os.line = @@l[:S1]
    assert_equal(@@l[:S1], os.line)
    assert_equal(@@l[:S1].name, os.name)
  end

  def test_sequence
    # placeholder
    assert(@@l[:S1].sequence.placeholder?)
    assert(@@l[:S2].sequence.placeholder?)
    s = @@l[:S1].clone
    s.sequence = "ACCT"
    assert(!s.sequence.placeholder?)
    # sequence is string
    assert_equal("ACCT", s.sequence)
    # rc
    assert_equal("AGGT", s.sequence.rc)
    # GFA2 allowed alphabet is larger than GFA1
    assert_nothing_raised { s.validate }
    s.sequence = ";;;{}"
    assert_raises(RGFA::FormatError) { s.validate }
    s = @@l[:S2].clone
    s.sequence = ";;;{}"
    assert_nothing_raised { s.validate }
    # to_sequence
    assert_kind_of(RGFA::Placeholder,"*".to_sequence)
    assert_kind_of(String,"ACG".to_sequence)
  end

  def test_sequence_rc
    assert_equal("gcatcgatcgt","acgatcgatgc".rc)
    # case
    assert_equal("gCaTCgatcgt","acgatcGAtGc".rc)
    # wildcards
    assert_equal("gcatcnatcgt","acgatngatgc".rc)
    assert_equal("gcatcYatcgt","acgatRgatgc".rc)
    # RNA
    assert_equal("gcaucgaucgu","acgaucgaugc".rc(rna: true))
    assert_equal("===.",".===".rc)
    # valid
    assert_raises(RGFA::ValueError){"acgatXgatgc".rc}
    assert_nothing_raised{"acgatXgatgc".rc(valid: true)}
    # placeholder
    assert_equal("*","*".rc)
    assert_raises(RGFA::ValueError){"**".rc}
  end

end
