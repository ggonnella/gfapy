require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAEdit < Test::Unit::TestCase

  def test_rename
    gfa = ["S\t0\t*", "S\t1\t*", "S\t2\t*", "L\t0\t+\t2\t-\t12M",
    "C\t1\t+\t0\t+\t12\t12M", "P\t4\t2+,0-\t12M"].to_rgfa
    gfa.rename("0", "X")
    assert_raises(RGFA::NotFoundError){gfa.segment!("0")}
    assert_equal([:"X", :"1", :"2"].sort, gfa.segment_names.sort)
    assert_equal("L\tX\t+\t2\t-\t12M", gfa.links[0].to_s)
    assert_equal("C\t1\t+\tX\t+\t12\t12M", gfa.containments[0].to_s)
    assert_equal("P\t4\t2+,X-\t12M", gfa.paths[0].to_s)
    assert_raises(RGFA::NotFoundError){gfa.segment!("0").dovetails(:R)}
    assert_equal("L\tX\t+\t2\t-\t12M", gfa.segment("X").dovetails(:R)[0].to_s)
    assert_equal("C\t1\t+\tX\t+\t12\t12M", gfa.segment!("1").contained[0].to_s)
    assert_raises(RGFA::NotFoundError){gfa.segment!("0").containers}
    assert_equal("C\t1\t+\tX\t+\t12\t12M", gfa.segment!("X").containers[0].to_s)
    assert_equal("P\t4\t2+,X-\t12M", gfa.segment!("X").paths[0].to_s)
  end

  def test_multiply_segment
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*\tRC:i:600",
         "S\t1\t*\tRC:i:6000",
         "S\t2\t*\tRC:i:60000"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    p = "P\t3\t2+,0-\t12M"
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal(s, gfa.segments.map(&:to_s))
    assert_equal([l], gfa.links.select{|n|!n.virtual?}.map(&:to_s))
    assert_equal([c], gfa.containments.map(&:to_s))
    assert_equal(l, gfa.link(["1", :E], ["2", :B]).to_s)
    assert_equal(c, gfa.containments_between("1", "0")[0].to_s)
    assert_raises(RGFA::NotFoundError){gfa.link(["1a", :E], ["2", :B])}
    assert_raises(RGFA::NotFoundError){gfa.containments_between("5", "0")}
    assert_equal(6000, gfa.segment("1").RC)
    gfa.multiply("1", 2)
    assert_equal(l, gfa.link(["1", :E], ["2", :B]).to_s)
    assert_equal(c, gfa.containments_between("1", "0")[0].to_s)
    assert_not_equal(nil, gfa.link(["1b", :E], ["2", :B]))
    assert_not_equal([], gfa.containments_between("1b", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(3000, gfa.segment("1b").RC)
    gfa.multiply("1b", 3 , copy_names:["6","7"])
    assert_equal(l, gfa.link(["1", :E], ["2", :B]).to_s)
    assert_not_equal(nil, gfa.link(["1b", :E], ["2", :B]))
    assert_not_equal(nil, gfa.link(["6", :E], ["2", :B]))
    assert_not_equal(nil, gfa.link(["7", :E], ["2", :B]))
    assert_not_equal([], gfa.containments_between("1b", "0"))
    assert_not_equal([], gfa.containments_between("6", "0"))
    assert_not_equal([], gfa.containments_between("7", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(1000, gfa.segment("1b").RC)
    assert_equal(1000, gfa.segment("6").RC)
    assert_equal(1000, gfa.segment("7").RC)
  end

  def test_multiply_segment_copy_names
    gfa = ["H\tVN:Z:1.0",
           "S\t1\t*\tRC:i:600",
           "S\t1b\t*\tRC:i:6000",
           "S\t2\t*\tRC:i:60000",
           "S\t3\t*\tRC:i:60000"].to_rgfa
    gfa.multiply("2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2B")}
    gfa.multiply("2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2C")}
    gfa.multiply("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy")}
    gfa.multiply("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy2")}
    gfa.multiply("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy3")}
    gfa.multiply("2_copy", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy4")}
    gfa.multiply("2_copy4", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy5")}
    gfa.multiply("2", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("4")}
    gfa.multiply("1b", 2)
    assert_nothing_raised {gfa.segment!("1c")}
    gfa.multiply("1b", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("1b2")}
    gfa.multiply("1b", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("1b_copy")}
    gfa.multiply("1b_copy", 2, copy_names: :lowcase)
    assert_nothing_raised {gfa.segment!("1b_copz")}
    gfa.multiply("1b_copy", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("1b_copyB")}
  end

end
