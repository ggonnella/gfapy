require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFACigar < Test::Unit::TestCase

  def test_from_string_nonempty
    assert_equal(RGFA::CIGAR.new([
      RGFA::CIGAR::Operation.new(12,:M),
      RGFA::CIGAR::Operation.new(1,:D),
      RGFA::CIGAR::Operation.new(2,:I)]),"12M1D2I".to_cigar)
  end

  def test_from_string_empty
    assert_equal(RGFA::Placeholder,"*".to_cigar.class)
  end

  def test_from_string_invalid
    assert_raises(RGFA::FormatError){"12x1D2I".to_cigar}
  end

  def test_to_s_nonempty
    assert_equal("12M1D2I",
      RGFA::CIGAR.new([
      RGFA::CIGAR::Operation.new(12,:M),
      RGFA::CIGAR::Operation.new(1,:D),
      RGFA::CIGAR::Operation.new(2,:I)]).to_s)
  end

end
