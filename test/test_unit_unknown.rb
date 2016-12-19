require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::Unknown < Test::Unit::TestCase

  @@u = RGFA::Line::Unknown.new(["a"])

  def test_new
    assert_nothing_raised { RGFA::Line::Unknown.new(["a"]) }
  end

  def test_to_s
    assert_equal("?record_type?\ta\tco:Z:line_created_by_RGFA", @@u.to_s)
  end

  def test_tags
    assert_raise(NoMethodError) {@@u.xx}
    assert_nil(@@u.get(:xx))
    assert_raise(NoMethodError) {@@u.xx = 1}
    assert_raise(RGFA::RuntimeError) {@@u.set(:xx, 1)}
  end

  def test_virtual
    assert(@@u.virtual?)
  end

end
