require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::ReferencesVirtual < Test::Unit::TestCase

  def test_virtual_lines
    # for each kind of line
    #   test that generated virtual lines are virtual
    #   test class of generated virtual lines
    #   add real line corresponding to virtual line
    #   test that references are correctly updated
    g = RGFA.new(version: :gfa2)
    path1 = "O\tp1\tp2- b+ c- e-c+-".to_rgfa_line
    path2 = "O\tp2\tf+ a+".to_rgfa_line
    g << path1
    path1.items.each do |i|
      assert(i.line.virtual?)
    end
    g << path2
    assert(!path1.items[0].line.virtual?)
    path1.items[1..-1].each_with_index do |i|
      assert(i.line.virtual?)
    end
  end

end
