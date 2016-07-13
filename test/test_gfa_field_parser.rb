require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAFieldParser < Test::Unit::TestCase

  def test_parse_opfield
    o = "AA:i:1"
    assert_equal([:AA,:i,1], o.parse_optfield)
    assert_equal([:AA,:i,"1"], o.parse_optfield(parse_datastring: false))
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
    assert_raise(RGFA::FieldParser::FormatError) {"AA:A:AA".parse_optfield}
  end

  def test_parse_datastring_A
    assert_equal("1", "1".parse_datastring(:A))
    assert_raise(RGFA::FieldParser::FormatError) do
      "12".parse_datastring(:A)
    end
  end

  def test_parse_datastring_i
    assert_equal(12, "12".parse_datastring(:i))
    assert_raise(RGFA::FieldParser::FormatError) do
      "1A".parse_datastring(:i)
    end
  end

  def test_parse_datastring_f
    assert_equal(1.2, "1.2".parse_datastring(:f))
    assert_raise(RGFA::FieldParser::FormatError) do
      "1A".parse_datastring(:f)
    end
  end

  def test_parse_datastring_Z
    assert_equal("1.2", "1.2".parse_datastring(:Z))
    assert_raise(RGFA::FieldParser::FormatError) do
      "1.2\ta".parse_datastring(:Z)
    end
  end

  def test_parse_datastring_H
    assert_equal("1A", "1A".parse_datastring(:H))
    assert_equal([26], "1A".parse_datastring(:H, :lazy => false))
    assert_raise(RGFA::FieldParser::FormatError) do
      "1Z".parse_datastring(:H)
    end
  end

  def test_parse_datastring_B
    assert_equal("c,12,12,12", "c,12,12,12".parse_datastring(:B))
    assert_equal([12,12,12], "c,12,12,12".parse_datastring(:B,:lazy => false))
    assert_equal([1.2,1.2,1.2], "f,1.2,1.2,1.2".parse_datastring(:B,
                 :lazy => false))
    assert_raise(RGFA::FieldParser::FormatError) do
      "f.1.1.1".parse_datastring(:H)
    end
  end

  def test_parse_datastring_J
    assert_equal("{\"1\":2}", "{\"1\":2}".parse_datastring(:J))
    assert_equal({"1" => 2}, "{\"1\":2}".parse_datastring(:J, :lazy => false))
    assert_raise(RGFA::FieldParser::FormatError) do
      "1\t2".parse_datastring(:J)
    end
  end

end
