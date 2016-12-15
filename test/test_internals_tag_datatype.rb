require_relative "../lib/rgfa.rb"
require "test/unit"

TestInternals ||= Module.new
class TestInternals::TagDatatype < Test::Unit::TestCase

  def test_datatype_value_independent
    assert_equal(:Z, "string".default_gfa_tag_datatype)
    assert_equal(:i, 1.default_gfa_tag_datatype)
    assert_equal(:f, 1.0.default_gfa_tag_datatype)
    assert_equal(:H, RGFA::ByteArray.new([]).default_gfa_tag_datatype)
    assert_equal(:B, RGFA::NumericArray.new([]).default_gfa_tag_datatype)
    assert_equal(:J, {}.default_gfa_tag_datatype)
  end

  def test_datatype_arrays
    assert_equal(:B, [1,1].default_gfa_tag_datatype)
    assert_equal(:B, [1.0,1.0].default_gfa_tag_datatype)
    assert_equal(:J, [1,1.0].default_gfa_tag_datatype)
    assert_equal(:J, ["1",1].default_gfa_tag_datatype)
    assert_equal(:J, [1.0,"1.0"].default_gfa_tag_datatype)
    assert_equal(:J, ["z","z"].default_gfa_tag_datatype)
    assert_equal(:J, [[1,2,3],[3,4,5]].default_gfa_tag_datatype)
  end

end
