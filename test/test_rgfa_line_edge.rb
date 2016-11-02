require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineLink < Test::Unit::TestCase

  def test_to_gfa1
    e1 = "E\t*\t1\t+\t2\t90\t100$\t0\t10\t10M".to_rgfa_line
    l1 = "L\t1\t+\t2\t+\t10M"
    assert_equal(l1, e1.to_gfa1_s)
    e2 = "E\t*\t1\t+\t2\t0\t20\t80\t100$\t20M".to_rgfa_line
    l2 = "L\t2\t+\t1\t+\t20M"
    assert_equal(l2, e2.to_gfa1_s)
    e3 = "E\t*\t4\t-\t3\t0\t30\t0\t30\t30M".to_rgfa_line
    l3 = "L\t3\t-\t4\t+\t30M"
    assert_equal(l3, e3.to_gfa1_s)
    e4 = "E\t*\t3\t-\t4\t60\t100$\t60\t100$\t40M".to_rgfa_line
    l4 = "L\t3\t+\t4\t-\t40M"
    assert_equal(l4, e4.to_gfa1_s)
  end

end
