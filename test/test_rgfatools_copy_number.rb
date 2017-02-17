require_relative "../lib/rgfatools.rb"
require "test/unit"

class TestRGFAToolsCopyNumber < Test::Unit::TestCase

  def test_delete_low_coverage_segments
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/copynum.1.#{sfx}")
      assert_equal([:"0",:"1",:"2"], gfa.segment_names)
      gfa.delete_low_coverage_segments(10)
      assert_equal([:"1",:"2"], gfa.segment_names)
      gfa.delete_low_coverage_segments(100)
      assert_equal([:"2"], gfa.segment_names)
      gfa.delete_low_coverage_segments(1000)
      assert_equal([], gfa.segment_names)
    end
  end

  def test_compute_copy_numbers
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/copynum.2.#{sfx}")
      assert_nothing_raised { gfa.compute_copy_numbers(9) }
      assert_equal(0, gfa.segment!("0").cn)
      assert_equal(1, gfa.segment!("1").cn)
      assert_equal(2, gfa.segment!("2").cn)
      assert_equal(3, gfa.segment!("3").cn)
    end
  end

  def test_apply_copy_number
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/copynum.2.#{sfx}")
      assert_equal([:"0",:"1",:"2",:"3"], gfa.segment_names)
      gfa.compute_copy_numbers(9)
      gfa.apply_copy_numbers
      assert_equal([:"1",:"2",:"3",:"2*2",:"3*2",:"3*3"], gfa.segment_names)
      gfa.compute_copy_numbers(9)
      assert(gfa.segments.map(&:cn).all?{|cn|cn == 1})
    end
  end

end
