require_relative "../lib/rgfatools.rb"
require "test/unit"

class TestRGFAToolsCopyNumber < Test::Unit::TestCase

  def test_delete_low_coverage_segments
    gfa = ["S\t0\t*\tRC:i:600\tLN:i:100",
           "S\t1\t*\tRC:i:6000\tLN:i:100",
           "S\t2\t*\tRC:i:60000\tLN:i:100"].to_rgfa
    assert_equal([:"0",:"1",:"2"], gfa.segment_names)
    gfa.delete_low_coverage_segments(10)
    assert_equal([:"1",:"2"], gfa.segment_names)
    gfa.delete_low_coverage_segments(100)
    assert_equal([:"2"], gfa.segment_names)
    gfa.delete_low_coverage_segments(1000)
    assert_equal([], gfa.segment_names)
  end

  def test_compute_copy_numbers
    gfa = ["S\t0\t*\tRC:i:10\tLN:i:100",
           "S\t1\t*\tRC:i:1000\tLN:i:100",
           "S\t2\t*\tRC:i:2000\tLN:i:100",
           "S\t3\t*\tRC:i:3000\tLN:i:100"].to_rgfa
    assert_nothing_raised { gfa.compute_copy_numbers(9) }
    assert_equal(0, gfa.segment!("0").cn)
    assert_equal(1, gfa.segment!("1").cn)
    assert_equal(2, gfa.segment!("2").cn)
    assert_equal(3, gfa.segment!("3").cn)
  end

  def test_apply_copy_number
    gfa = ["S\t0\t*\tRC:i:10\tLN:i:100",
           "S\t1\t*\tRC:i:1000\tLN:i:100",
           "S\t2\t*\tRC:i:2000\tLN:i:100",
           "S\t3\t*\tRC:i:3000\tLN:i:100"].to_rgfa
    assert_equal([:"0",:"1",:"2",:"3"], gfa.segment_names)
    gfa.compute_copy_numbers(9)
    gfa.apply_copy_numbers
    assert_equal([:"1",:"2",:"3",:"2b",:"3b",:"3c"], gfa.segment_names)
    gfa.compute_copy_numbers(9)
    assert(gfa.segments.map(&:cn).all?{|cn|cn == 1})
  end

end
