require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFAEdit < Test::Unit::TestCase

  def test_delete_sequences
    gfa = GFA.new
    seqs = ["ACCAGCTAGCGAGC", "CGCTAGTGCTG", "GCTAGCTAG"]
    seqs.each_with_index {|seq, i| gfa << "S\t#{i}\t#{seq}" }
    assert_equal(seqs, gfa.segments.map{|s|s.sequence})
    gfa.delete_sequences
    assert_equal(["*","*","*"], gfa.segments.map{|s|s.sequence})
  end

  def test_delete_alignments
    gfa = ["S\t0\t*", "S\t1\t*", "S\t2\t*", "L\t1\t+\t2\t+\t12M",
    "C\t1\t+\t0\t+\t12\t12M", "P\t4\t2+,0-\t12M,12M"].to_gfa
    assert_equal([[12,"M"]], gfa.links[0].overlap)
    assert_equal([[12,"M"]], gfa.containments[0].overlap)
    assert_equal([[[12,"M"]],[[12,"M"]]], gfa.paths[0].cigars)
    gfa.delete_alignments
    assert_equal("*", gfa.links[0].overlap)
    assert_equal("*", gfa.containments[0].overlap)
    assert_equal(["*"], gfa.paths[0].cigars)
  end

  def test_rename_segment
    gfa = ["S\t0\t*", "S\t1\t*", "S\t2\t*", "L\t0\t+\t2\t+\t12M",
    "C\t1\t+\t0\t+\t12\t12M", "P\t4\t2+,0-\t12M,12M"].to_gfa
    gfa.rename_segment("0", "X")
    assert_equal(["X", "1", "2"], gfa.segment_names)
    assert_equal("L\tX\t+\t2\t+\t12M", gfa.links[0].to_s)
    assert_equal("C\t1\t+\tX\t+\t12\t12M", gfa.containments[0].to_s)
    assert_equal("P\t4\t2+,X-\t12M,12M", gfa.paths[0].to_s)
    assert_nothing_raised { gfa.send(:validate_connect) }
    assert_equal([], gfa.links_of(["0", :E]))
    assert_equal("L\tX\t+\t2\t+\t12M", gfa.links_of(["X", :E])[0].to_s)
    assert_equal("C\t1\t+\tX\t+\t12\t12M", gfa.contained_in("1")[0].to_s)
    assert_equal([], gfa.containing("0"))
    assert_equal("C\t1\t+\tX\t+\t12\t12M", gfa.containing("X")[0].to_s)
    assert_equal([], gfa.paths_with("0"))
    assert_equal("P\t4\t2+,X-\t12M,12M", gfa.paths_with("X")[0].to_s)
  end

  def test_multiply_segment
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*\tRC:i:600".to_gfa_line,
         "S\t1\t*\tRC:i:6000".to_gfa_line,
         "S\t2\t*\tRC:i:60000".to_gfa_line]
    l = "L\t1\t+\t2\t+\t12M".to_gfa_line
    c = "C\t1\t+\t0\t+\t12\t12M".to_gfa_line
    p = "P\t3\t2+,0-\t12M,12M".to_gfa_line
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal(s, gfa.segments)
    assert_equal([l], gfa.links)
    assert_equal([c], gfa.containments)
    assert_equal(l, gfa.link(["1", :E], ["2", :B]))
    assert_equal(c, gfa.containment("1", "0"))
    assert_equal(nil, gfa.link(["1a", :E], ["2", :B]))
    assert_equal(nil, gfa.containment("5", "0"))
    assert_equal(6000, gfa.segment("1").RC)
    gfa.duplicate_segment("1")
    assert_nothing_raised { gfa.send(:validate_connect) }
    assert_equal(l, gfa.link(["1", :E], ["2", :B]))
    assert_equal(c, gfa.containment("1", "0"))
    assert_not_equal(nil, gfa.link(["1b", :E], ["2", :B]))
    assert_not_equal(nil, gfa.containment("1b", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(3000, gfa.segment("1b").RC)
    gfa.multiply_segment("1b", 3 , copy_names:["6","7"])
    assert_nothing_raised { gfa.send(:validate_connect) }
    assert_equal(l, gfa.link(["1", :E], ["2", :B]))
    assert_not_equal(nil, gfa.link(["1b", :E], ["2", :B]))
    assert_not_equal(nil, gfa.link(["6", :E], ["2", :B]))
    assert_not_equal(nil, gfa.link(["7", :E], ["2", :B]))
    assert_not_equal(nil, gfa.containment("1b", "0"))
    assert_not_equal(nil, gfa.containment("6", "0"))
    assert_not_equal(nil, gfa.containment("7", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(1000, gfa.segment("1b").RC)
    assert_equal(1000, gfa.segment("6").RC)
    assert_equal(1000, gfa.segment("7").RC)
    gfa.multiply_segment("2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2B")}
    gfa.multiply_segment("2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2C")}
    gfa.multiply_segment("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy")}
    gfa.multiply_segment("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy2")}
    gfa.multiply_segment("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy3")}
    gfa.multiply_segment("2_copy", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy4")}
    gfa.multiply_segment("2_copy4", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy5")}
    gfa.multiply_segment("2", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("4")}
    gfa.multiply_segment("1b", 2)
    assert_nothing_raised {gfa.segment!("1c")}
    gfa.multiply_segment("1b", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("1b2")}
    gfa.multiply_segment("1b", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("1b_copy")}
    gfa.multiply_segment("1b_copy", 2, copy_names: :lowcase)
    assert_nothing_raised {gfa.segment!("1b_copz")}
    gfa.multiply_segment("1b_copy", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("1b_copyB")}
  end

  def test_delete_low_coverate_segments
    gfa = ["S\t0\t*\tRC:i:600\tLN:i:100",
           "S\t1\t*\tRC:i:6000\tLN:i:100",
           "S\t2\t*\tRC:i:60000\tLN:i:100"].to_gfa
    assert_equal(["0","1","2"], gfa.segment_names)
    gfa.delete_low_coverage_segments(10)
    assert_equal(["1","2"], gfa.segment_names)
    assert_nothing_raised { gfa.send(:validate_connect) }
    gfa.delete_low_coverage_segments(100)
    assert_equal(["2"], gfa.segment_names)
    assert_nothing_raised { gfa.send(:validate_connect) }
    gfa.delete_low_coverage_segments(1000)
    assert_equal([], gfa.segment_names)
    assert_nothing_raised { gfa.send(:validate_connect) }
  end

  def test_mean_coverage
    gfa = ["S\t0\t*\tRC:i:1000\tLN:i:100",
           "S\t1\t*\tRC:i:2000\tLN:i:100",
           "S\t2\t*\tRC:i:3000\tLN:i:100",
           "S\t3\t*\tLN:i:100"].to_gfa
    assert_equal(20, gfa.mean_coverage(["0","1","2"]))
    assert_raises(RuntimeError) {gfa.mean_coverage(["0","2","3"])}
    assert_raises(RuntimeError) {gfa.mean_coverage(["0","2","4"])}
  end

  def test_compute_copy_numbers
    gfa = ["S\t0\t*\tRC:i:10\tLN:i:100",
           "S\t1\t*\tRC:i:1000\tLN:i:100",
           "S\t2\t*\tRC:i:2000\tLN:i:100",
           "S\t3\t*\tRC:i:3000\tLN:i:100"].to_gfa
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
           "S\t3\t*\tRC:i:3000\tLN:i:100"].to_gfa
    assert_equal(["0","1","2","3"], gfa.segment_names)
    gfa.compute_copy_numbers(9)
    gfa.apply_copy_numbers
    assert_equal(["1","2","3","2b","3b","3c"], gfa.segment_names)
    gfa.compute_copy_numbers(9)
    assert(gfa.segments.map(&:cn).all?{|cn|cn == 1})
    assert_nothing_raised { gfa.send(:validate_connect) }
  end

end
