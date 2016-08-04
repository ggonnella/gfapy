require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAFieldValidator < Test::Unit::TestCase

  def test_field_gfa_field_validate_i
    assert_nothing_raised { "1".validate_gfa_field!(:i) }
    assert_nothing_raised { "12".validate_gfa_field!(:i) }
    assert_nothing_raised { "-12".validate_gfa_field!(:i) }
    assert_raise(RGFA::FieldParser::FormatError) {"1A".validate_gfa_field!(:i)}
    assert_raise(RGFA::FieldParser::FormatError) {"A1".validate_gfa_field!(:i)}
    assert_raise(RGFA::FieldParser::FormatError) {"2.1".validate_gfa_field!(:i)}
  end

  def test_field_gfa_field_validate_A
    assert_nothing_raised { "A".validate_gfa_field!(:A) }
    assert_raise(RGFA::FieldParser::FormatError) {"AA".validate_gfa_field!(:A)}
  end

  def test_field_gfa_field_validate_f
    assert_nothing_raised { "-12.1".validate_gfa_field!(:f) }
    assert_nothing_raised { "-12.1E-2".validate_gfa_field!(:f) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "2.1X".validate_gfa_field!(:f)
    end
  end

  def test_field_gfa_field_validate_Z
    assert_nothing_raised { "-12.1E-2".validate_gfa_field!(:Z) }
  end

  def test_field_gfa_field_validate_H
    assert_nothing_raised { "0A12121EFF".validate_gfa_field!(:H) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "21X1".validate_gfa_field!(:H)
    end
  end

  def test_field_gfa_field_validate_B
    assert_nothing_raised { "i,12,-5".validate_gfa_field!(:B) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "C,X1".validate_gfa_field!(:B)
    end
    assert_raise(RGFA::FieldParser::FormatError) do
      "f.1.1".validate_gfa_field!(:B)
    end
  end

  def test_field_gfa_field_validate_J
    assert_nothing_raised {"{\"1\":2}".validate_gfa_field!(:J) }
    assert_raise(RGFA::FieldParser::FormatError) do
      "1\t2".validate_gfa_field!(:J)
    end
  end

end
