require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFACigar < Test::Unit::TestCase

  def test_cigar
    assert_raises(TypeError){"12x1D2I".cigar_operations}
    assert_equal("*","*".cigar_operations)
    assert_equal([[12,"M"],[1,"D"],[2,"I"]],"12M1D2I".cigar_operations)
  end

end
