require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAFieldParser < Test::Unit::TestCase

  def test_parse_opfield
    o = "AA:i:1"
    assert_equal([:AA,:i,"1"], o.parse_optfield)
    assert_raise(RGFA::FieldParser::FormatError) do
      "1A:A:A".parse_optfield
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "_A:A:A".parse_optfield
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "A:A:A".parse_optfield
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "AAA:A:A".parse_optfield
    end
    assert_raise(RGFA::FieldParser::FormatError) {"AA:C:1".parse_optfield}
    assert_raise(RGFA::FieldParser::FormatError) {"AA:AA:1".parse_optfield}
    assert_raise(RGFA::FieldParser::FormatError) {"AA:a:1".parse_optfield}
  end

  def test_parse_datastring_A
    assert_equal("1", "1".parse_datastring(:A))
  end

  def test_parse_datastring_i
    assert_equal(12, "12".parse_datastring(:i))
  end

  def test_parse_datastring_f
    assert_equal(1.2, "1.2".parse_datastring(:f))
  end

  def test_parse_datastring_Z
    assert_equal("1.2", "1.2".parse_datastring(:Z))
  end

  def test_parse_datastring_H
    assert_equal([26], "1A".parse_datastring(:H))
  end

  def test_parse_datastring_B
    assert_equal([12,12,12], "c,12,12,12".parse_datastring(:B))
    assert_equal([1.2,1.2,1.2], "f,1.2,1.2,1.2".parse_datastring(:B))
  end

  def test_parse_datastring_J
    assert_equal({"1" => 2}, "{\"1\":2}".parse_datastring(:J))
  end

end
