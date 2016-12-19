require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::LineEquivalence < Test::Unit::TestCase

  @@a      = "S\tA\t*\tLN:i:8\txx:Z:a".to_rgfa_line
  @@b      = "S\tB\t*\tLN:i:10".to_rgfa_line
  @@c      = "C\tA\t+\tB\t+\t10\t*".to_rgfa_line
  @@l      = "L\tA\t+\tB\t+\t*".to_rgfa_line
  @@e      = "E\t1\tA+\tB-\t0\t100$\t20\t121\t*".to_rgfa_line

  @@a_ln   = "S\tA\t*\tLN:i:10\txx:Z:a".to_rgfa_line
  @@a_seq  = "S\tA\tACCTTCGT\tLN:i:8\txx:Z:a".to_rgfa_line
  @@a_gfa2 = "S\tA\t8\tACCTTCGT\txx:Z:a".to_rgfa_line
  @@a_noxx = "S\tA\t*\tLN:i:8".to_rgfa_line
  @@a_yy   = "S\tA\t*\tLN:i:8\txx:Z:a\tyy:Z:b".to_rgfa_line
  @@l_from = "L\tC\t+\tB\t+\t*".to_rgfa_line
  @@e_name = "E\t2\tA+\tB-\t0\t100$\t20\t121\t*".to_rgfa_line

  @@h_a    = {:record_type => :S,
              :name => :A,
              :LN => 8,
              :xx => "a"}
  @@h_a_rt = @@h_a.clone
  @@h_a_rt[:record_type] = :X
  @@h_a_pl = @@h_a.clone
  @@h_a_pl[:name] = RGFA::Placeholder.new
  @@h_a_name = @@h_a.clone
  @@h_a_name[:name] = :B
  @@h_a_seq = @@h_a.clone
  @@h_a_seq[:sequence] = "ACCTTCGT"
  @@h_a_ln = @@h_a.clone
  @@h_a_ln[:LN] = 10
  @@h_a_LNstr = @@h_a.clone
  @@h_a_LNstr[:LN] = "8"
  @@h_a_noxx = @@h_a.clone
  @@h_a_noxx.delete(:xx)
  @@h_a_yy = @@h_a.clone
  @@h_a_yy[:yy] = "b"
  @@h_a_gfa2 = {:record_type => :S,
                :sid => :A,
                :slen => 8,
                :xx => "a"}


  def test_line_placeholder
    assert(!@@a.placeholder?)
    assert(!@@b.placeholder?)
  end

  def test_line_diff_two_segments
    adiffb = [[:different, :positional_field, :name, "A", "B"],
              [:exclusive, :<, :tag, :xx, :Z, "a"],
              [:different, :tag, :LN, :i, "8", :i, "10"]]
    assert_equal(adiffb, @@a.diff(@@b))
    bdiffa = [[:different, :positional_field, :name, "B", "A"],
              [:exclusive, :>, :tag, :xx, :Z, "a"],
              [:different, :tag, :LN, :i, "10", :i, "8"]]
    assert_equal(bdiffa, @@b.diff(@@a))
    assert_equal([], @@a.diff(@@a))
    assert_equal([], @@b.diff(@@b))
  end

  def test_line_diffscript_two_segments
    acpy = @@a.clone
    eval(acpy.diffscript(@@b, "acpy"))
    assert_not_equal(@@b.to_s, @@a.to_s)
    assert_equal(@@b.to_s, acpy.to_s)
    bcpy = @@b.clone
    eval(bcpy.diffscript(@@a, "bcpy"))
    assert_not_equal(@@a.to_s, @@b.to_s)
    assert_equal(@@a.to_s, bcpy.to_s)
  end

  def test_equal
    # ==
    assert(!(@@a == @@b))
    assert(!(@@a == @@a_ln))
    assert(!(@@a == @@a_seq))
    assert(!(@@a == @@a_gfa2))
    assert(!(@@a == @@a_noxx))
    assert(@@b == @@b.clone)
    assert(@@a == @@a.clone)
  end

  def test_pointer_equality
    # eql?
    assert(@@a.eql?(@@a))
    assert(!@@a.eql?(@@a.clone))
    # equal?
    assert(@@a.equal?(@@a))
    assert(!@@a.equal?(@@a.clone))
  end

  def test_eql_fields
    # same object
    assert(@@a.eql_fields?(@@a))
    # clone
    assert(@@a.eql_fields?(@@a.clone))
    # positional field difference
    assert(!@@l.eql_fields?(@@l_from))
    assert(@@l.eql_fields?(@@l_from, [:from]))
    # positional field difference: name alias
    assert(!@@e.eql_fields?(@@e_name))
    assert(@@e.eql_fields?(@@e_name, [:eid]))
    assert(@@e.eql_fields?(@@e_name, [:name]))
    # positional field difference: placeholder in line
    assert(@@a.eql_fields?(@@a_seq))
    # positional field difference: placeholder in reference
    assert(@@a_seq.eql_fields?(@@a))
    # tag difference
    assert(!@@a.eql_fields?(@@a_ln))
    assert(@@a.eql_fields?(@@a_ln, [:LN]))
    # additional tag in line
    assert(@@a.eql_fields?(@@a_noxx))
    assert(!@@a_noxx.eql_fields?(@@a))
    # missing tag in line
    assert(!@@a.eql_fields?(@@a_yy))
    assert(@@a_yy.eql_fields?(@@a))
    assert(@@a.eql_fields?(@@a_yy, [:yy]))
    # gfa1 vs gfa2
    assert(@@a.eql_fields?(@@a_gfa2, [:slen]))
    assert(@@a_gfa2.eql_fields?(@@a, [:LN]))
    # record_type
    assert(!@@c.eql_fields?(@@l))
    assert(!@@l.eql_fields?(@@c))
    assert(@@c.eql_fields?(@@l, [:record_type]))
    assert(@@l.eql_fields?(@@c, [:record_type, :pos]))
  end

  def test_field_values
    assert(@@a.field_values?(@@h_a))
    # record_type difference
    assert(!@@a.field_values?(@@h_a_rt))
    assert(@@a.field_values?(@@h_a_rt, [:record_type]))
    # positional field difference
    assert(!@@a.field_values?(@@h_a_name))
    assert(@@a.field_values?(@@h_a_name, [:name]))
    # positional field difference: placeholder in line
    assert(@@a.field_values?(@@h_a_seq))
    # positional field difference: placeholder in hash is compared
    assert(!@@a.field_values?(@@h_a_pl))
    assert(@@a.field_values?(@@h_a_pl, [:name]))
    # tag difference
    assert(!@@a.field_values?(@@h_a_ln))
    assert(@@a.field_values?(@@h_a_ln, [:LN]))
    # encoded value
    assert(@@a.field_values?(@@h_a_LNstr))
    # additional tag in line
    assert(@@a.field_values?(@@h_a_noxx))
    # missing tag in line
    assert(!@@a.field_values?(@@h_a_yy))
    assert(@@a.field_values?(@@h_a_yy, [:yy]))
    # gfa1 vs gfa2
    assert(@@a.field_values?(@@h_a_gfa2, [:slen]))
  end

end
