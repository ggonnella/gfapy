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
    :E  => "E\t*\t1\t+\t2\t10\t20\t30\t40\t*",
    :F  => "F\t1\t+\t5\t11\t21\t31\t41\t*",
    :G  => "G\t*\t1\t<\t>\t2\t1000\t1",
    :U  => "U\t*\t1 2 3",
    :O  => "O\t*\t1 2 3",
  }
  @@f = Hash[@@s.map{|k,v|[k,v.split("\t")]}]
  @@l = Hash[@@s.map{|k,v|[k,v.to_rgfa_line]}]

  @@fieldnames = {
    :S1 => [:name, :sequence],
    :L  => [:from, :from_orient, :to, :to_orient, :overlap],
    :C  => [:from, :from_orient, :to, :to_orient, :pos, :overlap],
    :P  => [:path_name, :segment_names, :overlaps],
    :S2 => [:sid, :slen, :sequence],
    :E  => [:eid, :sid1, :or2, :sid2, :beg1, :end1, :beg2, :end2, :alignment],
    :F  => [:sid, :or, :external, :s_beg, :s_end, :f_beg, :f_end, :alignment],
    :G  => [:gid, :sid1, :d1, :d2, :sid2, :disp, :var],
    :U  => [:pid, :items],
    :O  => [:pid, :items],
  }

  # alternative values to set tests
  @@v1 = {
    :S1 => {:name => :sx, :sequence => "accg"},
    :L => {:from => :a1, :from_orient => :-, :to => :a2, :to_orient => :-,
           :overlap => "12M".to_alignment},
    :C => {:from => :cx, :from_orient => :-, :to => :cy, :to_orient => :-,
           :pos => 123, :overlap => "120M".to_alignment},
    :P => {:path_name => :px, :segment_names => [[:x,:+].to_oriented_segment,
           [:y,:-].to_oriented_segment], :overlaps => ["10M".to_alignment]},
    :S2 => {:sid => :s2s, :slen => 999, :sequence => "gggg"},
    :E  => {:eid => :e2e, :sid1 => :s2s, :or2 => :-, :sid2 => :t2t,
            :beg1 => 0, :end1 => "100$".to_position,
            :beg2 => 10, :end2 => "110$".to_position,
            :alignment => "10M1I10M1D80M".to_alignment},
    :F  => {:sid => :s2s, :or => :-, :external => :ex2ex,
            :s_beg => 0, :s_end => "100$".to_position,
            :f_beg => 10, :f_end => "110$".to_position,
            :alignment => "10M1I10M1D80M".to_alignment},
    :G  => {:gid => :g2g, :sid1 => :s2s, :d1 => :>, :d2 => :<, :sid2 => :t2t,
            :disp => 2000, :var => 100},
    :O  => {:pid => :O100, :items => [:x1, :x2, :x3]},
    :U  => {:pid => :U100, :items => [:x1, :x2, :x3]},
  }
  @@v2 = {
    :S1 => {:name => :xs, :sequence => "aggc"},
    :L => {:from => :a5, :from_orient => :+, :to => :a7, :to_orient => :+,
           :overlap => "9M3I3M".to_alignment},
    :C => {:from => :cp, :from_orient => :+, :to => :cl, :to_orient => :+,
           :pos => 213, :overlap => "110M4D10M".to_alignment},
    :P => {:path_name => :pu, :segment_names => [[:k,:-].to_oriented_segment,
           [:l,:+].to_oriented_segment], :overlaps => ["11M".to_alignment]},
    :S2 => {:sid => :s4s, :slen => 1999, :sequence => "aaaa"},
    :E  => {:eid => :e4e, :sid1 => :s4s, :or2 => :+, :sid2 => :t4t,
            :beg1 => 10, :end1 => "110$".to_position,
            :beg2 => 0, :end2 => "100$".to_position,
            :alignment => "10M1I20M1D80M".to_alignment},
    :F  => {:sid => :s4s, :or => :+, :external => :ex4ex,
            :s_beg => 10, :s_end => "110$".to_position,
            :f_beg => 0, :f_end => "100$".to_position,
            :alignment => "10M1I20M1D80M".to_alignment},
    :G  => {:gid => :g4g, :sid1 => :s4s, :d1 => :<, :d2 => :>, :sid2 => :t4t,
            :disp => 3000, :var => 200},
    :O  => {:pid => :O200, :items => [:x7, :x6, :x3]},
    :U  => {:pid => :U200, :items => [:x6, :x7, :x4]},
  }
  @@aliases = {
      :S1 => {:name => :sid}, :P => {:path_name => :name},
      :S2 => {:sid => :name}, :E => {:eid => :name}, :G => {:gid => :name},
      :U => {:pid => :name}, :O => {:pid => :name},
      :C => {:from => :container, :from_orient => :container_orient,
             :to => :contained, :to_orient => :contained_orient}
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

  def test_fieldnames
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

end
