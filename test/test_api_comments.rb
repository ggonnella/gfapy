require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Comments < Test::Unit::TestCase

  def test_initialize
   l = RGFA::Line::Comment.new(["hallo"])
   assert_equal("# hallo", l.to_s)
   l = RGFA::Line::Comment.new(["hallo", "\t"])
   assert_equal("#\thallo", l.to_s)
  end

  def test_fields
   l = RGFA::Line::Comment.new(["hallo"])
   assert_equal("hallo", l.content)
   assert_equal(" ", l.spacer)
   l.content = "hello"
   assert_equal("hello", l.content)
   assert_equal("# hello", l.to_s)
   l.spacer = "  "
   assert_equal("hello", l.content)
   assert_equal("#  hello", l.to_s)
  end

  def test_validation
   assert_raises(RGFA::FormatError) {RGFA::Line::Comment.new(["hallo\nhallo"])}
   assert_raises(RGFA::FormatError) {RGFA::Line::Comment.new(["hallo", "\n"])}
   assert_nothing_raised {
       RGFA::Line::Comment.new(["hallo", "\n"], validate: 0) }
   l = RGFA::Line::Comment.new(["hallo"])
   assert_nothing_raised {l.content = "hallo\n"}
   assert_raises(RGFA::FormatError) { l.to_s }
   l.content = "hallo"
   assert_nothing_raised {l.to_s}
   assert_nothing_raised {l.spacer = "\n"}
   assert_raises(RGFA::FormatError) { l.to_s }
   l = RGFA::Line::Comment.new(["hallo"], validate: 5)
   assert_raises(RGFA::FormatError) { l.content = "hallo\n" }
   assert_raises(RGFA::FormatError) { l.spacer = "\n" }
  end

  def test_from_string
    str = "# this is a comment"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(str[2..-1], l.content)
    assert_equal(" ", l.spacer)
    str = "#this is another comment"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(str[1..-1], l.content)
    assert_equal("", l.spacer)
    str = "#\t and this too"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(str[3..-1], l.content)
    assert_equal(str[1..2], l.spacer)
    str = "#: and this too"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Comment, l.class)
    assert_equal(str[1..-1], l.content)
    assert_equal("", l.spacer)
  end

  def test_to_s
    str = "# this is a comment"
    l = str.to_rgfa_line
    assert_equal(str, l.to_s)
    str = "#this is another\tcomment"
    l = str.to_rgfa_line
    assert_equal(str, l.to_s)
    str = "#this is another\tcomment"
    l = str.to_rgfa_line
    l.spacer = " "
    assert_equal("# "+str[1..-1], l.to_s)
  end

  def test_tags
    assert_raises(RGFA::ValueError) {
      RGFA::Line::Comment.new(["hallo", " ", "zz:Z:hallo"]) }
    l = "# hallo zz:Z:hallo".to_rgfa_line
    assert_equal("hallo zz:Z:hallo", l.content)
    assert_raises(NoMethodError) { l.zz  }
    assert_raises(NoMethodError) { l.zz = 1 }
    assert_raises(RGFA::RuntimeError) { l.set(:zz, 1) }
    assert_nil(l.get(:zz))
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

  def test_rgfa_comments
    gfa = RGFA.new
    c1 = "#this is a comment"
    c2 = "# this is also a comment"
    c3 = "#and \tthis too!"
    assert_nothing_raised { gfa << c1 }
    assert_nothing_raised { gfa << c2 }
    assert_nothing_raised { gfa << c3 }
    assert_equal([c1,c2,c3], gfa.comments.map(&:to_s))
    assert_equal(c1, gfa.comments[0].to_s)
    gfa.rm(gfa.comments[0])
    assert_equal([c2,c3], gfa.comments.map(&:to_s))
    gfa.comments[0].disconnect
    assert_equal([c3], gfa.comments.map(&:to_s))
  end

end
