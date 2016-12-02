require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::ReferencesVirtual < Test::Unit::TestCase

  def test_edges_gaps_create_virtual_segments
    data = [
      [:gfa1, {:lines => ["L\ta\t+\tb\t-\t*", "C\ta\t-\tb\t+\t100\t*"],
               :m1 => :oriented_from, :m2 => :oriented_to,
               :sA => "S\ta\t*", :sB => "S\tb\t*",
               :collection => :edges}],
      [:gfa2, {:lines => ["E\t*\ta+\tb-\t0\t100\t900\t1000$\t*"],
               :m1 => :sid1, :m2 => :sid2,
               :sA => "S\ta\t1000\t*", :sB => "S\tb\t1000\t*",
               :collection => :edges}],
      [:gfa2, {:lines => ["G\t*\ta+\tb-\t1000\t100"],
               :m1 => :sid1, :m2 => :sid2,
               :sA => "S\ta\t1000\t*", :sB => "S\tb\t1000\t*",
               :collection => :gaps}]
    ]
    data.each do |v,values|
      values[:lines].each do |linestr|
        g = RGFA.new(version: v)
        g << (line = linestr.to_rgfa_line)
        assert_equal([:a, :b], g.segments.map(&:name))
        g.segments.each {|s| assert(s.virtual?)}
        g << (sA = values[:sA].to_rgfa_line)
        assert_equal([:a, :b].sort, g.segments.map(&:name).sort)
        assert(!g.segment(:a).virtual?)
        assert(g.segment(:b).virtual?)
        assert_equal(sA, line.send(values[:m1]).line)
        assert_equal(sA, g.segment(:a))
        assert_equal([line], sA.send(values[:collection]))
        g << (sB = values[:sB].to_rgfa_line)
        assert_equal([:a, :b].sort, g.segments.map(&:name).sort)
        assert(!g.segment(:b).virtual?)
        assert_equal(sB, line.send(values[:m2]).line)
        assert_equal(sB, g.segment(:b))
        assert_equal([line], sB.send(values[:collection]))
      end
    end
  end

  def test_fragments_create_virtual_segments
    g = RGFA.new(version: :gfa2)
    g << (fr = "F\ta\tread10-\t0\t10\t990\t1000$\t*".to_rgfa_line)
    assert_equal([:a], g.segments.map(&:name))
    assert(g.segment(:a).virtual?)
    g << (sA = "S\ta\t1000\t*".to_rgfa_line)
    assert_equal([:a], g.segments.map(&:name))
    assert(!g.segment(:a).virtual?)
    assert_equal(sA, fr.sid)
    assert_equal(sA, g.segment(:a))
    assert_equal([fr], sA.fragments)
  end

  def test_paths_create_virtual_links
    g = RGFA.new(version: :gfa1)
    path = "P\tp1\tb+,ccc-,e+\t10M1I2M,15M".to_rgfa_line
    g << path
    path.segment_names.each {|i| assert(i.line.virtual?)}
    assert_equal([:b, :ccc, :e], g.segments.map(&:name))
    g << (sB = "S\tb\t*".to_rgfa_line)
    assert(!path.segment_names[0].line.virtual?)
    assert_equal(sB, path.segment_names[0].line)
    assert_equal([path], sB.paths)
    path.links.each {|i| assert(i.virtual?)}
    g << (l = "L\tccc\t+\tb\t-\t2M1D10M".to_rgfa_line)
    assert(!path.links[0].virtual?)
    assert_equal(l, path.links[0])
    assert_equal([path], l.paths)
    g << (l = "L\tccc\t-\te\t+\t15M".to_rgfa_line)
    assert(!path.links[1].virtual?)
    assert_equal(l, path.links[1])
    assert_equal([path], l.paths)
  end

  def test_ordered_groups_create_virtual_unknown_records
    g = RGFA.new(version: :gfa2)
    path = "O\tp1\tchildpath- b+ c- edge-".to_rgfa_line
    g << path
    path.items.each do |i|
      assert(i.line.virtual?)
      assert_equal(nil, i.line.record_type)
    end
    g << (childpath = "O\tchildpath\tf+ a+".to_rgfa_line)
    assert(!path.items[0].line.virtual?)
    assert_equal(childpath, path.items[0].line)
    assert_equal([path], childpath.paths)
    g << (sB = "S\tb\t1000\t*".to_rgfa_line)
    assert(!path.items[1].line.virtual?)
    assert_equal(sB, path.items[1].line)
    assert_equal([path], sB.paths)
    g << (edge = "E\tedge\te-\tc+\t0\t100\t900\t1000$\t*".to_rgfa_line)
    assert(!path.items[-1].line.virtual?)
    assert_equal(edge, path.items[-1].line)
    assert_equal([path], edge.paths)
  end

  def test_unordered_groups_create_virtual_unknown_records
    g = RGFA.new(version: :gfa2)
    set = "U\tset\tchildpath b childset edge".to_rgfa_line
    g << set
    set.items.each do |i|
      assert(i.virtual?)
      assert_equal(nil, i.record_type)
    end
    g << (childpath = "O\tchildpath\tf+ a+".to_rgfa_line)
    assert(!set.items[0].virtual?)
    assert_equal(childpath, set.items[0])
    assert_equal([set], childpath.sets)
    g << (sB = "S\tb\t1000\t*".to_rgfa_line)
    assert(!set.items[1].virtual?)
    assert_equal(sB, set.items[1])
    assert_equal([set], sB.sets)
    g << (childset = "U\tchildset\tg edge2".to_rgfa_line)
    assert(!set.items[2].virtual?)
    assert_equal(childset, set.items[2])
    assert_equal([set], childset.sets)
    g << (edge = "E\tedge\te-\tc+\t0\t100\t900\t1000$\t*".to_rgfa_line)
    assert(!set.items[3].virtual?)
    assert_equal(edge, set.items[3])
    assert_equal([set], edge.sets)
  end

end
