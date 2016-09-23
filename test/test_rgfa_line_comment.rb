require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineComment < Test::Unit::TestCase

  def test_from_string
    str = "#this is a comment"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(str[1..-1], l.content)
  end

end
