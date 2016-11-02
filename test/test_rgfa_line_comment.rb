require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineComment < Test::Unit::TestCase

  def test_from_string
    str = "# this is a comment"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(str[1..-1], l.content)
    # no initial space or the present of tabs does not matter
    str = "#this is another\tcomment"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(str[1..-1], l.content)
  end

  def test_to_s
    str = "# this is a comment"
    l = str.to_rgfa_line
    assert_equal(str, l.to_s)
    str = "#this is another\tcomment"
    l = str.to_rgfa_line
    assert_equal(str, l.to_s)
  end

  def test_to_gfa1
    str = "# this is a comment"
    l = str.to_rgfa_line(version: :"2.0")
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(:"2.0", l.version)
    assert_equal(str, l.to_s)
    assert_equal(:"2.0", l.to_gfa2.version)
    assert_equal(str, l.to_gfa2.to_s)
    assert_equal(:"1.0", l.to_gfa1.version)
    assert_equal(str, l.to_gfa1.to_s)
  end

  def test_to_gfa2
    str = "# this is a comment"
    l = str.to_rgfa_line(version: :"1.0")
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(:"1.0", l.version)
    assert_equal(str, l.to_s)
    assert_equal(:"1.0", l.to_gfa1.version)
    assert_equal(str, l.to_gfa1.to_s)
    assert_equal(:"2.0", l.to_gfa2.version)
    assert_equal(str, l.to_gfa2.to_s)
  end

end
