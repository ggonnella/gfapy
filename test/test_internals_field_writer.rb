require_relative "../lib/rgfa.rb"
require "test/unit"

# XXX: see parser
class (TestInternals||=Module.new)::FieldWriter < Test::Unit::TestCase

  def test_field_writer_i
    assert_equal("13", 13.to_gfa_field)
  end

  def test_field_writer_f
    assert_equal("1.3", 1.3.to_gfa_field)
  end

  def test_field_writer_Z
    assert_equal("1B", "1B".to_gfa_field)
  end

  def test_field_writer_H
    assert_equal("0D0D0D", [13,13,13].to_byte_array.to_gfa_field)
    assert_raise(RGFA::ValueError) do
      [13,13,1.3].to_byte_array.to_gfa_field
    end
    assert_raise(RGFA::ValueError) do
      [13,13,350].to_byte_array.to_gfa_field
    end
  end

  def test_field_writer_B
    assert_equal("C,13,13,13", [13,13,13].to_gfa_field)
    assert_equal("f,1.3,1.3,1.3", [1.3,1.3,1.3].to_gfa_field)
    assert_raise(RGFA::ValueError) do
      [13,1.3,1.3].to_gfa_field(datatype: :B)
    end
  end

  def test_field_writer_J
    assert_equal("[\"A\",12]", ["A", 12].to_gfa_field)
    assert_equal("{\"A\":12}", {"A" => 12}.to_gfa_field)
  end

  def test_field_writer_as_tag
    assert_equal("AA:i:13", 13.to_gfa_tag(:AA))
  end

end
