require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::SegmentEnd < Test::Unit::TestCase

  @@sym = :a
  @@ref = "S\ta\t*\txx:Z:1.0".to_rgfa_line
  @@invalid_sym = :"a\ta"
  @@invalid_ref = []
  @@se_s = RGFA::SegmentEnd.new(@@sym, :L)
  @@se_r = RGFA::SegmentEnd.new(@@ref, :R)
  @@se_s_str = "aL"
  @@se_r_str = "aR"
  @@se_s_sym = :"aL"
  @@se_r_sym = :"aR"

  def test_new
    assert_nothing_raised { RGFA::SegmentEnd.new(@@sym, :L) }
    # no validation on creation:
    assert_nothing_raised { RGFA::SegmentEnd.new(@@invalid_sym, :X) }
  end

  def test_to_segment_end
    assert_equal(@@se_s, @@se_s.to_segment_end)
    assert(@@se_s.eql?(@@se_s.to_segment_end))
    assert_equal(@@se_s, [:a, :L].to_segment_end)
    assert_kind_of(RGFA::SegmentEnd, [:a, :L].to_segment_end)
    assert_raise(RGFA::ValueError) {[:a, :L, :L].to_segment_end}
    # to_segment_end from array performs validation:
    assert_raise(RGFA::ValueError) {[:a, :X].to_segment_end}
  end

  def test_segment
    assert_equal(@@sym, @@se_s.segment)
    assert_equal(@@ref, @@se_r.segment)
    se2 = RGFA::SegmentEnd.new(@@sym, :R)
    se2.segment = @@ref
    assert_equal(@@ref, se2.segment)
  end

  def test_end_type
    assert_equal(:L, @@se_s.end_type)
    assert_equal(:R, @@se_r.end_type)
    se2 = RGFA::SegmentEnd.new(@@sym, :L)
    se2.end_type = :R
    assert_equal(:R, se2.end_type)
  end

  def test_name
    assert_equal(@@sym, @@se_s.name)
    assert_equal(@@sym, @@se_r.name)
  end

  def test_validate
    assert_nothing_raised { @@se_s.validate }
    assert_nothing_raised { @@se_r.validate }
    se1 = RGFA::SegmentEnd.new(:a, :X)
    assert_raise(RGFA::ValueError) { se1.validate }
  end

  def test_invert
    inv_s = @@se_s.invert
    assert_equal(@@se_s.segment, inv_s.segment)
    assert_equal(:R, inv_s.end_type)
    inv_r = @@se_r.invert
    assert_equal(@@se_r.segment, inv_r.segment)
    assert_equal(:L, inv_r.end_type)
  end

  def test_to_s
    assert_equal(@@se_s_str, @@se_s.to_s)
    assert_equal(@@se_r_str, @@se_r.to_s)
  end

  def test_to_sym
    assert_equal(@@se_s_sym, @@se_s.to_sym)
    assert_equal(@@se_r_sym, @@se_r.to_sym)
  end

  def to_a
    assert_equal([:a, :L], @@se_s.to_a)
  end

  def test_equal
    se2 = RGFA::SegmentEnd.new(@@sym, :L)
    se3 = RGFA::SegmentEnd.new(@@ref, :R)
    assert(se2 == @@se_s)
    assert(se3 == @@se_r)
    # only name and end_type equivalence is checked, not segment
    assert(@@se_r != @@se_s)
    assert(@@se_r.invert == @@se_s)
    # equivalence to array
    assert(@@se_s == [:a,:L])
    assert(@@se_r == [:a,:R])
  end

  def test_comparison
    assert_equal(-1, [:a,:L].to_segment_end <=> [:b,:L].to_segment_end)
    assert_equal(0,  [:a,:L].to_segment_end <=> [:a,:L].to_segment_end)
    assert_equal(1,  [:b,:L].to_segment_end <=> [:a,:L].to_segment_end)
    assert_equal(-1, [:a,:L].to_segment_end <=> [:a,:R].to_segment_end)
    assert_equal(0,  [:a,:R].to_segment_end <=> [:a,:R].to_segment_end)
    assert_equal(1,  [:a,:R].to_segment_end <=> [:a,:L].to_segment_end)
  end

  def test_segment_ends_path
    sep = RGFA::SegmentEndsPath.new([[:a,:L],[:b,:R]].map(&:to_segment_end))
    assert_equal([[:b,:L],[:a,:R]], sep.reverse)
  end

end
