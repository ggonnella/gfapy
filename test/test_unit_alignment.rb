require_relative "../lib/rgfa.rb"
require "test/unit"

# note: API public methods are tested in test_api_alignment
class (TestUnit||=Module.new)::Alignment < Test::Unit::TestCase

  @@cigar_1 = RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I),
      RGFA::Alignment::CIGAR::Operation.new(0,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:P)])

  @@cigar_1_a = [
      RGFA::Alignment::CIGAR::Operation.new(12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I),
      RGFA::Alignment::CIGAR::Operation.new(0,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:P)]

  @@cigar_1_s = "12M1D2I0M1P"

  @@trace_1 = RGFA::Alignment::Trace.new([12,12,0])
  @@trace_1_s = "12,12,0"

  def test_to_cigar
    assert_equal(@@cigar_1, @@cigar_1.to_cigar)
    assert_equal(@@cigar_1, @@cigar_1_s.to_cigar)
    assert_equal(RGFA::Alignment::Placeholder, "*".to_cigar.class)
    assert_equal(@@cigar_1, @@cigar_1_a.to_cigar)
    assert_equal(RGFA::Alignment::Placeholder,
                 RGFA::Alignment::Placeholder.new.to_cigar.class)
  end

  def test_to_cigar_operation
    op = RGFA::Alignment::CIGAR::Operation.new(12,:M)
    assert_equal(op, [12, :M].to_cigar_operation)
    assert_equal(op, op.to_cigar_operation)
  end

  def test_to_trace
    assert_equal(@@trace_1, @@trace_1_s.to_trace)
    assert_equal(@@trace_1, @@trace_1.to_trace)
    assert_equal(RGFA::Alignment::Placeholder,
                 RGFA::Alignment::Placeholder.new.to_trace.class)
  end

end
