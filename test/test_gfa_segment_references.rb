require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFASegmentReferences < Test::Unit::TestCase

  def test_link_other
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    assert_equal(:"2", l.other(:"1"))
    assert_equal(:"1", l.other(:"2"))
    assert_raise(RuntimeError){l.other(:"0")}
  end

  def test_link_circular
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    assert_equal(false, l.circular?)
    l = "L\t1\t+\t1\t-\t*".to_rgfa_line
    assert_equal(true, l.circular?)
  end

  def test_containment_other
    c = "C\t1\t+\t2\t-\t12\t*".to_rgfa_line
    assert_equal(:"2", c.other(:"1"))
    assert_equal(:"1", c.other(:"2"))
    assert_raise(RuntimeError){c.other(:"0")}
  end

end
