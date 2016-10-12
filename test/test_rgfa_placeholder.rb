require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAPlaceholder < Test::Unit::TestCase

  def test_to_s
    assert_equal("*", RGFA::Placeholder.new.to_s)
  end

end
