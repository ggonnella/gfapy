require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFAOptfield < Test::Unit::TestCase

  def test_basic
    o = GFA::Optfield.new("AA","A","A")
    assert_equal(o.tag, "AA")
    assert_equal(o.type, "A")
    assert_equal(o.value, "A")
  end

  def test_from_s
    s = "AA:A:A"
    o = s.to_gfa_optfield
    assert_equal(o.tag, "AA")
    assert_equal(o.type, "A")
    assert_equal(o.value, "A")
  end

  def test_to_s
    o = GFA::Optfield.new("AA","A","A")
    s = "AA:A:A"
    assert_equal(o.to_s, s)
  end

  def test_validate_tag_name
    assert_nothing_raised { GFA::Optfield.new("AA","A","1") }
    assert_nothing_raised { GFA::Optfield.new("aa","A","1") }
    assert_nothing_raised { GFA::Optfield.new("a1","A","1") }
    assert_nothing_raised { GFA::Optfield.new("A1","A","1") }
    assert_raise(GFA::Optfield::TagError) { GFA::Optfield.new("1A","A","A") }
    assert_raise(GFA::Optfield::TagError) { GFA::Optfield.new("_A","A","A") }
    assert_raise(GFA::Optfield::TagError) { GFA::Optfield.new("A","A","A") }
    assert_raise(GFA::Optfield::TagError) { GFA::Optfield.new("AAA","A","A") }
  end

  def test_validate_type
    assert_nothing_raised { GFA::Optfield.new("AA","A","1") }
    assert_raise(GFA::Optfield::TypeError) { GFA::Optfield.new("AA","C","1") }
    assert_raise(GFA::Optfield::TypeError) { GFA::Optfield.new("AA","AA","1") }
    assert_raise(GFA::Optfield::TypeError) { GFA::Optfield.new("AA","a","1") }
  end

  def test_set_value
    o = GFA::Optfield.new("AA","A","A")
    o.value = "B"
    assert_equal(o.tag, "AA")
    assert_equal(o.type, "A")
    assert_equal(o.value, "B")
  end

  def test_set_invalid_value
    o = GFA::Optfield.new("AA","A","A")
    assert_raise(GFA::Optfield::ValueError) { o.value = "AB" }
  end

  def test_validate_value
    assert_nothing_raised { GFA::Optfield.new("AA","A","1") }
    assert_raise(GFA::Optfield::ValueError) { GFA::Optfield.new("AA","A","AA") }
    assert_nothing_raised { GFA::Optfield.new("AA","i","12") }
    assert_nothing_raised { GFA::Optfield.new("AA","i","-12") }
    assert_raise(GFA::Optfield::ValueError) {GFA::Optfield.new("AA","i","1A")}
    assert_raise(GFA::Optfield::ValueError) {GFA::Optfield.new("AA","i","A1")}
    assert_raise(GFA::Optfield::ValueError) {GFA::Optfield.new("AA","i","2.1")}
    assert_nothing_raised { GFA::Optfield.new("AA","f","-12.1") }
    assert_nothing_raised { GFA::Optfield.new("AA","f","-12.1E-2") }
    assert_raise(GFA::Optfield::ValueError) {GFA::Optfield.new("AA","f","2.1X")}
    assert_nothing_raised { GFA::Optfield.new("AA","Z","-12.1E-2") }
    assert_nothing_raised { GFA::Optfield.new("AA","H","0A12121EFF") }
    assert_raise(GFA::Optfield::ValueError) {GFA::Optfield.new("AA","H","21X1")}
    assert_nothing_raised { GFA::Optfield.new("AA","B","i,12,-5") }
    assert_raise(GFA::Optfield::ValueError) {GFA::Optfield.new("AA","B","C,X1")}
  end

end
