require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAFieldParser < Test::Unit::TestCase

  def test_parse_gfa_tag
    o = "AA:i:1"
    assert_equal([:AA,:i,"1"], o.parse_gfa_tag)
    assert_raise(RGFA::FieldParser::FormatError) do
      "1A:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "_A:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "A:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "AAA:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FieldParser::FormatError) {"AA:C:1".parse_gfa_tag}
    assert_raise(RGFA::FieldParser::FormatError) {"AA:AA:1".parse_gfa_tag}
    assert_raise(RGFA::FieldParser::FormatError) {"AA:a:1".parse_gfa_tag}
  end

  def test_parse_gfa_field_A
    assert_equal("1", "1".parse_gfa_field(datatype: :A))
  end

  def test_parse_gfa_field_i
    assert_equal(12, "12".parse_gfa_field(datatype: :i))
  end

  def test_parse_gfa_field_f
    assert_equal(1.2, "1.2".parse_gfa_field(datatype: :f))
  end

  def test_parse_gfa_field_Z
    assert_equal("1.2", "1.2".parse_gfa_field(datatype: :Z))
  end

  def test_parse_gfa_field_H
    assert_equal([26], "1A".parse_gfa_field(datatype: :H))
  end

  def test_parse_gfa_field_B
    assert_equal([12,12,12], "c,12,12,12".parse_gfa_field(datatype: :B))
    assert_equal([1.2,1.2,1.2], "f,1.2,1.2,1.2".parse_gfa_field(datatype: :B))
  end

  def test_parse_gfa_field_J
    assert_equal({"1" => 2}, "{\"1\":2}".parse_gfa_field(datatype: :J))
  end

end
