require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAFieldValidator < Test::Unit::TestCase

  def test_field_datastring_validate_i
    assert_nothing_raised { "1".parse_datastring(:i) }
    assert_nothing_raised { "12".parse_datastring(:i) }
    assert_nothing_raised { "-12".parse_datastring(:i) }
    assert_raise(RGFA::FieldParser::FormatError) {"1A".parse_datastring(:i)}
    assert_raise(RGFA::FieldParser::FormatError) {"A1".parse_datastring(:i)}
    assert_raise(RGFA::FieldParser::FormatError) {"2.1".parse_datastring(:i)}
  end

  def test_field_datastring_validate_A
    assert_nothing_raised { "A".parse_datastring(:A) }
    assert_raise(RGFA::FieldParser::FormatError) { "AA".parse_datastring(:A) }
  end

  def test_field_datastring_validate_f
    assert_nothing_raised { "-12.1".parse_datastring(:f) }
    assert_nothing_raised { "-12.1E-2".parse_datastring(:f) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "2.1X".parse_datastring(:f)
    end
  end

  def test_field_datastring_validate_Z
    assert_nothing_raised { "-12.1E-2".parse_datastring(:Z) }
  end

  def test_field_datastring_validate_H
    assert_nothing_raised { "0A12121EFF".parse_datastring(:H) }
    assert_raise(RGFA::FieldParser::FormatError) {"21X1".parse_datastring(:H)}
  end

  def test_field_datastring_validate_B
    assert_nothing_raised { "i,12,-5".parse_datastring(:B) }
    assert_raise(RGFA::FieldParser::FormatError) {"C,X1".parse_datastring(:B)}
  end

end
