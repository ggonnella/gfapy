require_relative "../lib/rgfatools.rb"
require "test/unit"

class TestRGFATools < Test::Unit::TestCase

  def test_basics
    assert_nothing_raised { RGFA.new }
    assert_nothing_raised { RGFA.included_modules.include?(RGFATools) }
  end

end
