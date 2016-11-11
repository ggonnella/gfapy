require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFACigar < Test::Unit::TestCase

  def test_from_string_nonempty
    assert_equal(RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I)]),"12M1D2I".to_cigar)
  end

  def test_from_string_empty
    assert_equal(RGFA::Alignment::Placeholder,"*".to_cigar.class)
  end

  def test_from_string_invalid
    assert_raises(RGFA::FormatError){"12x1D2I".to_cigar}
  end

  def test_to_s_nonempty
    assert_equal("12M1D2I",
      RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I)]).to_s)
  end

end
