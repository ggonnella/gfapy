require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFAOptfield < Test::Unit::TestCase

  def test_basic
    o = GFA::Optfield.new("AA","A","A")
    assert_equal("AA", o.tag)
    assert_equal("A", o.type)
    assert_equal("A", o.value)
  end

  def test_type_cast_by_getting_value
    o = GFA::Optfield.new("AA","A","1")
    assert_equal("1", o.value)
    assert_equal("1", o.value(false))
    o = GFA::Optfield.new("AA","i","12")
    assert_equal(12, o.value)
    assert_equal("12", o.value(false))
    o = GFA::Optfield.new("AA","f","1.2")
    assert_equal(1.2, o.value)
    assert_equal("1.2", o.value(false))
    o = GFA::Optfield.new("AA","Z","1.2")
    assert_equal("1.2", o.value)
    assert_equal("1.2", o.value(false))
    o = GFA::Optfield.new("AA","H","1A")
    assert_equal(26, o.value)
    assert_equal("1A", o.value(false))
    o = GFA::Optfield.new("AA","B","c,12,12,12")
    assert_equal([12,12,12], o.value)
    assert_equal("c,12,12,12",o.value(false))
    o = GFA::Optfield.new("AA","B","f,1.2,1.2,1.2")
    assert_equal([1.2,1.2,1.2], o.value)
    assert_equal("f,1.2,1.2,1.2", o.value(false))
  end

  def test_from_s
    s = "AA:A:A"
    o = s.to_gfa_optfield
    assert_equal("AA", o.tag)
    assert_equal("A", o.type)
    assert_equal("A", o.value)
  end

  def test_to_s
    o = GFA::Optfield.new("AA","A","A")
    s = "AA:A:A"
    assert_equal(s, o.to_s)
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
    assert_equal("AA", o.tag)
    assert_equal("A", o.type)
    assert_equal("B", o.value)
  end

  def test_type_cast_by_setting_value
    o = GFA::Optfield.new("AA","i","12")
    o.value = 13
    assert_equal(13, o.value)
    o = GFA::Optfield.new("AA","f","1.2")
    o.value = 1.3
    assert_equal(1.3, o.value)
    o = GFA::Optfield.new("AA","H","1A")
    o.value = 27
    assert_equal(27, o.value)
    assert_equal("1B", o.value(false))
    o = GFA::Optfield.new("AA","B","c,12,12")
    o.value = [13,13,13]
    assert_equal([13,13,13],o.value)
    assert_equal("i,13,13,13",o.value(false))
    o.value = [1.3,1.3,1.3]
    assert_equal([1.3,1.3,1.3],o.value)
    assert_equal("f,1.3,1.3,1.3",o.value(false))
    assert_raise(GFA::Optfield::ValueError) { o.value = [13,1.3,1.3] }
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
