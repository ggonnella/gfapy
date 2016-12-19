require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::ReferencesEdit < Test::Unit::TestCase

  # XXX
  def test_reference_fields_editing
    # for each kind of line
    #   for each reference field (hard code here)
    #     test that editing is allowed when line is not connected
    #     test that editing is blocked when line is connected
    #     test disconnection-editing-reconnection
    #     test other editing possibilities if any (see manual)
  end

end
