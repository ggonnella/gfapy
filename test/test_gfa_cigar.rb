require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFACigar < Test::Unit::TestCase

  def test_cigar_operations
    assert_equal([[12,"M"],[1,"D"],[2,"I"]],"12M1D2I".cigar_operations)
  end

  def test_cigar_operations_of_empty_cigar_string
    assert_equal("*","*".cigar_operations)
  end

  def test_cigar_operations_of_invalid_cigar_string
    assert_raises(TypeError){"12x1D2I".cigar_operations}
  end

end
