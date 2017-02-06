require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::OrientedLine < Test::Unit::TestCase

  @@sym = :a
  @@ref = "S\ta\t*\txx:Z:1.0".to_rgfa_line
  @@invalid_sym = :"a\ta"
  @@invalid_ref = []
  @@ol_s = RGFA::OrientedLine.new(@@sym, :+)
  @@ol_r = RGFA::OrientedLine.new(@@ref, :-)
  @@ol_inv = RGFA::OrientedLine.new(@@ref, :x)
  @@ol_s_str = "a+"
  @@ol_r_str = "a-"

  def test_new
    assert_nothing_raised { RGFA::OrientedLine.new(@@sym, :+) }
    # no validation on creation:
    assert_nothing_raised { RGFA::OrientedLine.new(@@invalid_sym, :X) }
  end

  def test_OL
    assert_equal(@@ol_s, OL[:a, :+])
    assert_kind_of(RGFA::OrientedLine, OL[:a, :+])
    assert_raise(ArgumentError) {OL[:a]}
    assert_raise(ArgumentError) {OL[:a,:+,:+]}
  end

  def test_to_oriented_line
    assert_equal(@@ol_s, @@ol_s.to_oriented_line)
    assert(@@ol_s.eql?(@@ol_s.to_oriented_line))
    assert_equal(@@ol_s, "a+".to_oriented_line)
    assert_kind_of(RGFA::OrientedLine, "a+".to_oriented_line)
    assert_equal(@@ol_s, [:a, :+].to_oriented_line)
    assert_kind_of(RGFA::OrientedLine, [:a, :+].to_oriented_line)
  end

  def test_line
    assert_equal(@@sym, @@ol_s.line)
    assert_equal(@@ref, @@ol_r.line)
    ol2 = RGFA::OrientedLine.new(@@sym, :-)
    ol2.line = @@ref
    assert_equal(@@ref, ol2.line)
  end

  def test_orient
    assert_equal(:+, @@ol_s.orient)
    assert_equal(:-, @@ol_r.orient)
    ol2 = RGFA::OrientedLine.new(@@sym, :+)
    ol2.orient = :-
    assert_equal(:-, ol2.orient)
  end

  def test_name
    assert_equal(@@sym, @@ol_s.name)
    assert_equal(@@sym, @@ol_r.name)
  end

  def test_validate
    assert_nothing_raised { @@ol_s.validate }
    assert_nothing_raised { @@ol_r.validate }
    ol1 = RGFA::OrientedLine.new(:a, :X)
    ol2 = RGFA::OrientedLine.new(@@invalid_ref, :+)
    ol3 = RGFA::OrientedLine.new(@@invalid_sym, :+)
    assert_raise(RGFA::ValueError) { ol1.validate }
    assert_raise(RGFA::TypeError) { ol2.validate }
    assert_raise(RGFA::FormatError) { ol3.validate }
  end

  def test_invert
    inv_s = @@ol_s.invert
    assert_equal(@@ol_s.line, inv_s.line)
    assert_equal(:-, inv_s.orient)
    inv_r = @@ol_r.invert
    assert_equal(@@ol_r.line, inv_r.line)
    assert_equal(:+, inv_r.orient)
    assert_raise(RGFA::ValueError) { @@ol_inv.invert }
  end

  def test_to_s
    assert_equal(@@ol_s_str, @@ol_s.to_s)
    assert_equal(@@ol_r_str, @@ol_r.to_s)
  end

  def test_equal
    ol2 = RGFA::OrientedLine.new(@@sym, :+)
    ol3 = RGFA::OrientedLine.new(@@ref, :-)
    assert(ol2 == @@ol_s)
    assert(ol3 == @@ol_r)
    # only name and orient equivalence is checked, not line
    assert(@@ol_r != @@ol_s)
    assert(@@ol_r.invert == @@ol_s)
    # equivalence to string
    assert(@@ol_s == "a+")
    assert(@@ol_r == "a-")
    # equivalence to symbol
    assert(@@ol_s == :"a+")
    assert(@@ol_r == :"a-")
    # equivalence to array
    assert(@@ol_s == [:a, :+])
    assert(@@ol_r == [:a, :-])
  end

  def test_block
    ol = RGFA::OrientedLine.new(:a, :+)
    assert_nothing_raised {ol.line = :b}
    assert_nothing_raised {ol.orient = :-}
    ol.block
    assert_raise(RGFA::RuntimeError) {ol.line = :b}
    assert_raise(RGFA::RuntimeError) {ol.orient = :-}
    ol.unblock
    assert_nothing_raised {ol.line = :b}
    assert_nothing_raised {ol.orient = :-}
  end

  def test_delegate_methods
    assert_equal("*", @@ol_r.field_to_s(:sequence))
    assert_equal("1.0", @@ol_r.xx)
    ol = RGFA::OrientedLine.new("S\ta\t*".to_rgfa_line, "+")
    ol.set("xx", 1)
    assert_equal("S\ta\t*\txx:i:1", ol.line.to_s)
  end

end
