require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAAlignment < Test::Unit::TestCase

  def test_from_string_cigar
    assert_equal(RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I)]),"12M1D2I".to_alignment)
  end

  def test_from_string_placeholder
    assert_equal(RGFA::Alignment::Placeholder,"*".to_alignment.class)
  end

  def test_from_string_trace
    assert_equal(RGFA::Alignment::Trace.new([12,14,15]),"12,14,15".to_alignment)
  end

  def test_from_string_invalid
    assert_raises(RGFA::FormatError){"12x1,D2I".to_alignment}
  end

  def test_from_array_cigar
    assert_equal(RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I)]),
      [RGFA::Alignment::CIGAR::Operation.new(12,:M),
       RGFA::Alignment::CIGAR::Operation.new(1,:D),
       RGFA::Alignment::CIGAR::Operation.new(2,:I)].to_alignment)
  end

  def test_from_array_trace
    assert_equal(RGFA::Alignment::Trace.new([12,14,15]),[12,14,15].to_alignment)
  end

  def test_from_array_invalid
    assert_raises(RGFA::FormatError){["12x1","2I"].to_alignment}
  end

end
