require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFALineHeader < Test::Unit::TestCase

  def test_from_string
    assert_nothing_raised { "H\tVN:Z:1.0".to_gfa_line }
    assert_equal(GFA::Line::Header, "H\tVN:Z:1.0".to_gfa_line.class)
    assert_raises(TypeError) { "H\tH2\tVN:Z:1.0".to_gfa_line }
    assert_raises(GFA::Optfield::ValueError) { "H\tVN:i:1.0".to_gfa_line }
  end

end
