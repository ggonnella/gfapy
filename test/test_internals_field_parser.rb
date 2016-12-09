require_relative "../lib/rgfa.rb"
require "test/unit"

# Test the methods in RGFA::Field::Parser using different data types
# and examples of valid and invalid data for each datatype

# XXX: positionals
# XXX: invalid data
# XXX: coordinate with validator/writer and with test_api_tags and
#      test_api_positionals

class (TestInternals||=Module.new)::FieldParser < Test::Unit::TestCase

  def test_parse_gfa_tag
    o = "AA:i:1"
    assert_equal([:AA,:i,"1"], o.parse_gfa_tag)
    assert_raise(RGFA::FormatError) do
      "1A:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FormatError) do
      "_A:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FormatError) do
      "A:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FormatError) do
      "AAA:A:A".parse_gfa_tag
    end
    assert_raise(RGFA::FormatError) {"AA:C:1".parse_gfa_tag}
    assert_raise(RGFA::FormatError) {"AA:AA:1".parse_gfa_tag}
    assert_raise(RGFA::FormatError) {"AA:a:1".parse_gfa_tag}
  end

  def test_parse_gfa_field_A
    assert_equal("1", "1".parse_gfa_field(:A))
  end

  def test_parse_gfa_field_i
    assert_equal(12, "12".parse_gfa_field(:i))
  end

  def test_parse_gfa_field_f
    assert_equal(1.2, "1.2".parse_gfa_field(:f))
  end

  def test_parse_gfa_field_Z
    assert_equal("1.2", "1.2".parse_gfa_field(:Z))
  end

  def test_parse_gfa_field_H
    assert_equal([26], "1A".parse_gfa_field(:H))
  end

  def test_parse_gfa_field_B
    assert_equal([12,12,12], "c,12,12,12".parse_gfa_field(:B))
    assert_equal([1.2,1.2,1.2], "f,1.2,1.2,1.2".parse_gfa_field(:B))
  end

  def test_parse_gfa_field_J
    assert_equal({"1" => 2}, "{\"1\":2}".parse_gfa_field(:J))
  end

end
