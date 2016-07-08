require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineHeader < Test::Unit::TestCase

  def test_from_string
    assert_nothing_raised { "H\tVN:Z:1.0".to_rgfa_line }
    assert_equal(RGFA::Line::Header, "H\tVN:Z:1.0".to_rgfa_line.class)
    assert_raises(TypeError) { "H\tH2\tVN:Z:1.0".to_rgfa_line }
    assert_raises(RGFA::Optfield::ValueError) { "H\tVN:i:1.0".to_rgfa_line }
  end

end
