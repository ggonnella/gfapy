require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Placeholders < Test::Unit::TestCase

  @@p = RGFA::Placeholder.new

  def test_to_s
    assert_equal("*", @@p.to_s)
  end

  def test_subclasses
    assert_equal(@@p, RGFA::Alignment::Placeholder.new)
  end

  def test_is_placeholder
    assert(@@p.placeholder?)
    assert("*".placeholder?)
    assert(!"1".placeholder?)
    assert(:*.placeholder?)
    assert(!:**.placeholder?)
    assert(!1.placeholder?)
    assert(!1.0.placeholder?)
    assert([].placeholder?)
    assert(![:x].placeholder?)
    assert(RGFA::Alignment::Placeholder.new.placeholder?)
  end

  def test_compatibility_methods
    # array/string
    assert(@@p.empty?)
    assert(@@p[1].placeholder?)
    assert(@@p[0..-1].placeholder?)
    assert_equal(0, @@p.length)
    # sequence
    assert(@@p.rc.placeholder?)
    # integer
    assert((@@p + 1).placeholder?)
    # validation
    assert_nothing_raised {@@p.validate}
  end

end
