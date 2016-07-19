require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAFieldValidator < Test::Unit::TestCase

  def test_field_datastring_validate_i
    assert_nothing_raised { "1".validate_datastring(:i) }
    assert_nothing_raised { "12".validate_datastring(:i) }
    assert_nothing_raised { "-12".validate_datastring(:i) }
    assert_raise(RGFA::FieldParser::FormatError) {"1A".validate_datastring(:i)}
    assert_raise(RGFA::FieldParser::FormatError) {"A1".validate_datastring(:i)}
    assert_raise(RGFA::FieldParser::FormatError) {"2.1".validate_datastring(:i)}
  end

  def test_field_datastring_validate_A
    assert_nothing_raised { "A".validate_datastring(:A) }
    assert_raise(RGFA::FieldParser::FormatError) {"AA".validate_datastring(:A)}
  end

  def test_field_datastring_validate_f
    assert_nothing_raised { "-12.1".validate_datastring(:f) }
    assert_nothing_raised { "-12.1E-2".validate_datastring(:f) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "2.1X".validate_datastring(:f)
    end
  end

  def test_field_datastring_validate_Z
    assert_nothing_raised { "-12.1E-2".validate_datastring(:Z) }
  end

  def test_field_datastring_validate_H
    assert_nothing_raised { "0A12121EFF".validate_datastring(:H) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "21X1".validate_datastring(:H)
    end
  end

  def test_field_datastring_validate_B
    assert_nothing_raised { "i,12,-5".validate_datastring(:B) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "C,X1".validate_datastring(:B)
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "f.1.1".validate_datastring(:B)
    end
  end

  def test_field_datastring_validate_J
    assert_nothing_raised {"{\"1\":2}".validate_datastring(:J) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "1\t2".validate_datastring(:J)
    end
  end

end
