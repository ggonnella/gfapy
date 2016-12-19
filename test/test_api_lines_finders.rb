require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
TestAPI::Lines ||= Module.new
class TestAPI::Lines::Finders < Test::Unit::TestCase

  def test_segment
    s = ["S\t1\t*","S\t2\t*"]
    gfa = s.to_rgfa
    assert_equal(s[0],gfa.segment("1").to_s)
    assert_equal(s[0],gfa.segment!("1").to_s)
    assert_equal(nil,gfa.segment("0"))
    assert_raises(RGFA::NotFoundError) {gfa.segment!("0").to_s}
  end

end
