require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Alignment < Test::Unit::TestCase

  @@cigar_1 = RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I),
      RGFA::Alignment::CIGAR::Operation.new(0,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:P)])
  @@cigar_1_s = "12M1D2I0M1P"

  @@cigar_gfa1_1_s = "1S2M3I4=5X6D7P8N9H"
  @@cigar_gfa1_1_c_s = "9H8I7P6I5X4=3D2M1D"
  @@cigar_gfa1_1_rlen = 2+4+5+6+8
  @@cigar_gfa1_1_qlen = 1+2+3+4+5

  @@cigar_gfa2_1_s = "1M2I3D4P"
  @@cigar_gfa2_1_c_s = "4P3I2D1M"
  @@cigar_gfa2_1_rlen = 1+3
  @@cigar_gfa2_1_qlen = 1+2

  @@trace_1 = RGFA::Alignment::Trace.new([12,12,0])
  @@trace_1_s = "12,12,0"

  @@cigar_invalid_value_1 = RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(-12,:M),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I)])
  @@cigar_invalid_value_2 = RGFA::Alignment::CIGAR.new([
      RGFA::Alignment::CIGAR::Operation.new(12,:Y),
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I)])
  @@cigar_invalid_type_1 = RGFA::Alignment::CIGAR.new([
      :x,
      RGFA::Alignment::CIGAR::Operation.new(1,:D),
      RGFA::Alignment::CIGAR::Operation.new(2,:I)])

  @@trace_invalid_value_1 =
      RGFA::Alignment::Trace.new([-2,1,12])
  @@trace_invalid_type_1 =
      RGFA::Alignment::Trace.new([12.0,1,12])

  @@cigar_empty = RGFA::Alignment::CIGAR.new([])
  @@trace_empty = RGFA::Alignment::Trace.new([])
  @@placeholder = RGFA::Alignment::Placeholder.new
  @@placeholder_s = "*"

  @@string_invalid = [
    "-12M1D2I", "12Y1D2I", "x1D2I",
    "-2,1,12", "12.0,1,12", "*x",
  ]

  @@cigar_op_1 = RGFA::Alignment::CIGAR::Operation.new(1,:D)
  @@cigar_op_1_len = 1
  @@cigar_op_1_code = :D
  @@cigar_op_2 = RGFA::Alignment::CIGAR::Operation.new(2,:I)
  @@cigar_op_2_len = 2
  @@cigar_op_2_code = :I

  def test_to_s
    assert_equal(@@cigar_1_s,     @@cigar_1_s.to_s)
    assert_equal(@@cigar_1_s,     @@cigar_1.to_s)
    assert_equal(@@trace_1_s,     @@trace_1.to_s)
    assert_equal(@@placeholder_s, @@placeholder.to_s)
    assert_equal(@@placeholder_s, @@cigar_empty.to_s)
    assert_equal(@@placeholder_s, @@trace_empty.to_s)
  end

  def test_to_alignment
    assert_equal(@@cigar_1,     @@cigar_1_s.to_alignment)
    assert_equal(@@trace_1,     @@trace_1_s.to_alignment)
    assert_equal(@@placeholder, @@placeholder_s.to_alignment)
    [@@cigar_1, @@trace_1, @@cigar_empty,
     @@trace_empty, @@placeholder].each do |alignment|
      assert_equal(alignment, alignment.to_alignment)
    end
    @@string_invalid.each do |string|
      assert_raises(RGFA::FormatError) { string.to_alignment }
    end
  end

  def test_decode_encode_invariant
    [@@trace_1_s, @@cigar_1_s, @@placeholder_s].each do |string|
      assert_equal(string, string.to_alignment.to_s)
    end
  end

  def test_is_placeholder
    [@@cigar_empty, @@trace_empty, @@placeholder, @@placeholder_s].each do |a|
      assert(a.placeholder?)
    end
    [@@cigar_1, @@cigar_1_s, @@trace_1, @@trace_1_s].each do |a|
      assert(!a.placeholder?)
    end
  end

  def test_validate
    assert_nothing_raised           { @@trace_1.validate! }
    assert_nothing_raised           { @@trace_empty.validate! }
    assert_nothing_raised           { @@cigar_1.validate! }
    assert_nothing_raised           { @@cigar_empty.validate! }
    assert_nothing_raised           { @@placeholder.validate! }
    assert_raises(RGFA::ValueError) { @@trace_invalid_value_1.validate! }
    assert_raises(RGFA::ValueError) { @@cigar_invalid_value_1.validate! }
    assert_raises(RGFA::ValueError) { @@cigar_invalid_value_2.validate! }
    assert_raises(RGFA::TypeError)  { @@trace_invalid_type_1.validate! }
    assert_raises(RGFA::TypeError)  { @@cigar_invalid_type_1.validate! }
  end

  def test_version_specific_validate
    assert_nothing_raised { @@cigar_gfa1_1_s.
                            to_alignment(version: :"1.0", valid: false)}
    assert_raises(RGFA::FormatError) { @@cigar_gfa1_1_s.
                            to_alignment(version: :"2.0", valid: false)}
    assert_nothing_raised { @@cigar_gfa2_1_s.
                            to_alignment(version: :"1.0", valid: false)}
    assert_nothing_raised { @@cigar_gfa2_1_s.
                            to_alignment(version: :"2.0", valid: false)}
  end

  def test_array_methods
    [@@cigar_empty, @@trace_empty].each {|a| assert(a.empty?) }
    [@@cigar_1, @@trace_1].each {|a| assert(!a.empty?) }
    assert_equal(RGFA::Alignment::CIGAR::Operation.new(1,:D), @@cigar_1[1])
    assert_equal(12, @@trace_1[1])
  end

  def test_cigar_operation_methods
    assert_equal(@@cigar_op_1_len, @@cigar_op_1.len)
    assert_equal(@@cigar_op_1_code, @@cigar_op_1.code)
    @@cigar_op_1.len =  @@cigar_op_2_len
    @@cigar_op_1.code = @@cigar_op_2_code
    assert_equal(@@cigar_op_2, @@cigar_op_1)
    assert_equal(@@cigar_op_2_len, @@cigar_op_1.len)
    assert_equal(@@cigar_op_2_code, @@cigar_op_1.code)
  end

  def test_cigar_complement
    assert_equal(@@cigar_gfa1_1_c_s,
                 @@cigar_gfa1_1_s.to_alignment(version: :"1.0").complement.to_s)
    assert_equal(@@cigar_gfa2_1_c_s,
                 @@cigar_gfa2_1_s.to_alignment.complement.to_s)
  end

  def test_cigar_length_on
    assert_equal(@@cigar_gfa1_1_rlen,
                 @@cigar_gfa1_1_s.to_alignment(version: :"1.0").
                 length_on_reference)
    assert_equal(@@cigar_gfa1_1_qlen,
                 @@cigar_gfa1_1_s.to_alignment(version: :"1.0").
                 length_on_query)
    assert_equal(@@cigar_gfa1_1_qlen,
                 @@cigar_gfa1_1_c_s.to_alignment(version: :"1.0").
                 length_on_reference)
    assert_equal(@@cigar_gfa1_1_rlen,
                 @@cigar_gfa1_1_c_s.to_alignment(version: :"1.0").
                 length_on_query)
    assert_equal(@@cigar_gfa2_1_rlen,
                 @@cigar_gfa2_1_s.to_alignment.length_on_reference)
    assert_equal(@@cigar_gfa2_1_qlen,
                 @@cigar_gfa2_1_s.to_alignment.length_on_query)
    assert_equal(@@cigar_gfa2_1_qlen,
                 @@cigar_gfa2_1_c_s.to_alignment.length_on_reference)
    assert_equal(@@cigar_gfa2_1_rlen,
                 @@cigar_gfa2_1_c_s.to_alignment.length_on_query)
  end

end
