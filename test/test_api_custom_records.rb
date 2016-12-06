require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::CustomRecords < Test::Unit::TestCase

  def test_from_string
    str1 = "X\tthis is a\tcustom line"
    l1 = str1.to_rgfa_line
    assert_equal(RGFA::Line::CustomRecord, l1.class)
    assert_equal(:X, l1.record_type)
    assert_equal("this is a", l1.field1)
    assert_equal("custom line", l1.field2)
  end

  def test_from_string_with_tags
    str2 = "XX\txx:i:2\txxxxxx\txx:i:1"
    l2 = str2.to_rgfa_line
    assert_equal(RGFA::Line::CustomRecord, l2.class)
    assert_equal(:XX, l2.record_type)
    assert_equal("xx:i:2", l2.field1)
    assert_equal("xxxxxx", l2.field2)
    assert_raise(NoMethodError){l2.field3}
    assert_equal(1, l2.xx)
    l2.xx = 3
    assert_equal(3, l2.xx)
    l2.field1 = "blabla"
    assert_equal("blabla", l2.field1)
  end

  def test_to_s
    str1 = "X\tthis is a\tcustom line"
    assert_equal(str1, str1.to_rgfa_line.to_s)
    str2 = "XX\txx:i:2\txxxxxx\txx:i:1"
    assert_equal(str2, str2.to_rgfa_line.to_s)
  end

  def test_add_custom_records
    gfa = RGFA.new(version: :gfa2)
    x1 = "X\tthis is a custom record"
    assert_nothing_raised { gfa << x1 }
    assert_equal([:X], gfa.custom_record_keys)
    assert_equal([x1], gfa.custom_records(:X).map(&:to_s))
  end

  def test_delete_custom_records
    gfa = RGFA.new(version: :gfa2)
    c = "X\tThis is a custom_record"
    gfa << c
    assert_equal([c], gfa.custom_records(:X).map(&:to_s))
    gfa.custom_records(:X).each(&:disconnect)
    assert_equal([], gfa.custom_records(:X))
  end

  def test_custom_records
    x = ["X\tVN:Z:1.0", "Y\ttesttesttest"]
    assert_equal(x[0..0], x.to_rgfa.custom_records(:X).map(&:to_s))
    assert_equal(x[1..1], x.to_rgfa.custom_records(:Y).map(&:to_s))
  end

end
