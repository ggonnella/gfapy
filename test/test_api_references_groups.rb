require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::ReferencesGroups < Test::Unit::TestCase

  def test_paths_references
    g = RGFA.new
    s = {}; l = {}
    [:a, :b, :c, :d, :e, :f].each do |name|
      g << (s[name] = "S\t#{name}\t*".to_rgfa_line)
    end
    path = "P\tp1\tf+,a+,b+,c-,e+\t*".to_rgfa_line
    assert_equal([OL[:f,:+], OL[:a,:+], OL[:b,:+], OL[:c,:-],
                  OL[:e,:+]], path.segment_names)
    assert_equal([], path.links)
    # connection
    g << path
    # links
    ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"].each do |name|
      g << (l[name] = name.chars.unshift("L").push("*").join("\t").to_rgfa_line)
    end
    # segment_names
    assert_equal([OL[s[:f],:+], OL[s[:a],:+], OL[s[:b],:+], OL[s[:c],:-],
                  OL[s[:e],:+]], path.segment_names)
    # links
    assert_equal([l["a-f-"],l["a+b+"],l["b+c-"],l["e-c+"]], path.links)
    # path disconnection
    path.disconnect
    assert_equal([OL[:f,:+], OL[:a,:+], OL[:b,:+], OL[:c,:-], OL[:e,:+]],
                 path.segment_names)
    assert_equal([], path.links)
    g << path
    # links disconnection cascades on paths:
    assert(path.connected?)
    l["a-f-"].disconnect
    assert(!path.connected?)
    assert_equal([OL[:f,:+], OL[:a,:+], OL[:b,:+], OL[:c,:-], OL[:e,:+]],
                 path.segment_names)
    g << path
    g << l["a-f-"]
    # segment disconnection cascades on links and then paths:
    assert(path.connected?)
    s[:a].disconnect
    assert(!path.connected?)
    assert_equal([OL[:f,:+], OL[:a,:+], OL[:b,:+], OL[:c,:-], OL[:e,:+]],
                 path.segment_names)
    assert_equal([], path.links)
  end

  def test_paths_backreferences
    g = RGFA.new
    s = {}; l = {}
    [:a, :b, :c, :d, :e, :f].each do |name|
      g << (s[name] = "S\t#{name}\t*".to_rgfa_line)
    end
    g << (path = "P\tp1\tf+,a+,b+,c-,e+\t*".to_rgfa_line)
    [:a, :b, :c, :e, :f].each do |sname|
      assert_equal([path], s[sname].paths)
    end
    assert_equal([], s[:d].paths)
    ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"].each do |name|
      g << (l[name] = name.chars.unshift("L").push("*").join("\t").to_rgfa_line)
    end
    ["a+b+", "b+c-", "e-c+", "a-f-"].each do |lname|
      assert_equal([path], l[lname].paths)
    end
    assert_equal([], l["c-d+"].paths)
    # disconnection effects
    path.disconnect
    ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"].each do |lname|
      assert_equal([], l[lname].paths)
    end
    [:a, :b, :c, :d, :e, :f].each do |sname|
      assert_equal([], s[sname].paths)
    end
    # reconnection
    path.connect(g)
    [:a, :b, :c, :e, :f].each do |sname|
      assert_equal([path], s[sname].paths)
    end
    assert_equal([], s[:d].paths)
    ["a+b+", "b+c-", "e-c+", "a-f-"].each do |lname|
      assert_equal([path], l[lname].paths)
    end
    assert_equal([], l["c-d+"].paths)
  end

  def test_ordered_groups_references
    g = RGFA.new
    s = {}
    [:a, :b, :c, :d, :e, :f].each do |name|
      g << (s[name] = "S\t#{name}\t1000\t*".to_rgfa_line)
    end
    path1_part1 = "O\tp1\tp2- b+".to_rgfa_line
    path1_part2 = "O\tp1\tc- e-c+-".to_rgfa_line
    path1 = path1_part2
    path2 = "O\tp2\tf+ a+".to_rgfa_line
    assert_equal([OL[:p2,:-], OL[:b,:+]], path1_part1.items)
    assert_equal([OL[:c,:-], OL[:"e-c+",:-]], path1_part2.items)
    assert_equal([OL[:f,:+], OL[:a,:+]], path2.items)
    assert_raise(RGFA::RuntimeError){path1.induced_set}
    assert_raise(RGFA::RuntimeError){path2.induced_set}
    # connection
    g << path1_part1
    g << path1_part2
    g << path2
    # edges
    e = {}
    ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-", "f-b+"].each do |name|
      coord1 = name[1] == "+" ? "900\t1000$" : "0\t100"
      coord2 = name[3] == "+" ? "0\t100" : "900\t1000$"
      g << (e[name] = ("E\t#{name}\t#{name[0..1]}\t#{name[2..3]}\t"+
                       "#{coord1}\t#{coord2}\t100M").to_rgfa_line)
    end
    # items
    assert_equal([OL[path2,:-], OL[s[:b],:+], OL[s[:c],:-], OL[e["e-c+"],:-]],
                 path1.items)
    assert_equal([OL[s[:f],:+], OL[s[:a],:+]], path2.items)
    # induced set
    assert_equal([OL[s[:f],:+], OL[e["a-f-"],:-], OL[s[:a],:+]],
                 path2.induced_set)
    assert_equal([OL[s[:a],:-], OL[e["a-f-"],:+], OL[s[:f],:-],
                  OL[e["f-b+"],:+], OL[s[:b],:+], OL[e["b+c-"],:+],
                  OL[s[:c],:-], OL[e["e-c+"],:-], OL[s[:e],:+]],
                 path1.induced_set)
    # backreferences
    [path2, s[:b], s[:c], e["e-c+"]].each do |line|
      assert_equal([path1], line.ordered_groups)
    end
    [s[:f], s[:a]].each do |line|
      assert_equal([path2], line.ordered_groups)
    end
    # group disconnection
    path1.disconnect
    assert_equal([OL[:p2,:-], OL[:b,:+], OL[:c,:-], OL[:"e-c+",:-]],
                 path1.items)
    assert_raise(RGFA::RuntimeError){path1.induced_set}
    assert_equal([OL[s[:f],:+], OL[s[:a],:+]], path2.items)
    [path2, s[:b], s[:c], e["e-c+"]].each do |line|
      assert_equal([], line.ordered_groups)
    end
    # group reconnection
    g << path1
    assert_equal([OL[path2,:-], OL[s[:b],:+], OL[s[:c],:-], OL[e["e-c+"],:-]],
                 path1.items)
    assert_equal([OL[s[:f],:+], OL[s[:a],:+]], path2.items)
    [path2, s[:b], s[:c], e["e-c+"]].each do |line|
      assert_equal([path1], line.ordered_groups)
    end
    # item disconnection cascades on group
    assert(path1.connected?)
    assert(path2.connected?)
    e["e-c+"].disconnect
    assert(!path1.connected?)
    assert(path2.connected?)
    g << e["e-c+"]
    g << path1
    # two-level disconnection cascade
    assert(path1.connected?)
    assert(path2.connected?)
    s[:f].disconnect
    assert(!path2.connected?)
    assert(!path1.connected?)
  end

  def test_unordered_groups_references
    g = RGFA.new
    s = {}
    set1 = "U\tset1\tb set2 c e-c+".to_rgfa_line
    set2 = "U\tset2\tg c-d+ path1".to_rgfa_line
    path1 = "O\tpath1\tf+ a+".to_rgfa_line
    assert_equal([:b, :set2, :c, :"e-c+"], set1.items)
    assert_equal([:g, :"c-d+", :path1], set2.items)
    # induced set of non-connected cannot be computed
    assert_raise(RGFA::RuntimeError){set1.induced_set}
    assert_raise(RGFA::RuntimeError){set2.induced_set}
    # connection
    g << set1
    g << set2
    # induced set cannot be computed, as long as not all references are solved
    assert_raise(RGFA::RuntimeError) {set1.induced_set}
    # connect items
    g << path1
    [:a, :b, :c, :d, :e, :f, :g].each do |name|
      g << (s[name] = "S\t#{name}\t1000\t*".to_rgfa_line)
    end
    e = {}
    ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"].each do |name|
      coord1 = name[1] == "+" ? "900\t1000$" : "0\t100"
      coord2 = name[3] == "+" ? "0\t100" : "900\t1000$"
      g <<  (e[name] = ("E\t#{name}\t#{name[0..1]}\t#{name[2..3]}\t"+
                       "#{coord1}\t#{coord2}\t100M").to_rgfa_line)
    end
    # items
    assert_equal([s[:b], set2, s[:c], e["e-c+"]], set1.items)
    assert_equal([s[:g], e["c-d+"], path1], set2.items)
    # induced set
    assert_equal([OL[s[:f],:+], OL[s[:a],:+]],
                 path1.induced_segments_set)
    assert_equal([s[:g], s[:c], s[:d], s[:f], s[:a]],
                 set2.induced_segments_set)
    assert_equal([s[:b], s[:g], s[:c], s[:d], s[:f], s[:a], s[:e]],
                 set1.induced_segments_set)
    assert_equal([e["c-d+"], e["a-f-"]],
                 set2.induced_edges_set)
    assert_equal([e["a+b+"],e["b+c-"],e["c-d+"],e["e-c+"],e["a-f-"]],
                 set1.induced_edges_set)
    assert_equal(set1.induced_segments_set + set1.induced_edges_set,
                 set1.induced_set)
    # backreferences
    [s[:b], set2, s[:c], e["e-c+"]].each do |line|
      assert_equal([set1], line.unordered_groups)
    end
    [s[:g], e["c-d+"], path1].each do |line|
      assert_equal([set2], line.unordered_groups)
    end
    # group disconnection
    set1.disconnect
    assert_equal([:b, :set2, :c, :"e-c+"], set1.items)
    [s[:b], set2, s[:c], e["e-c+"]].each do |line|
      assert_equal([], line.unordered_groups)
    end
    # group reconnection
    g << set1
    assert_equal([s[:b], set2, s[:c], e["e-c+"]], set1.items)
    [s[:b], set2, s[:c], e["e-c+"]].each do |line|
      assert_equal([set1], line.unordered_groups)
    end
    # item disconnection cascades on group
    assert(set1.connected?)
    e["e-c+"].disconnect
    assert(!set1.connected?)
    g << e["e-c+"]
    g << set1
    # multilevel disconnection cascade
    assert(path1.connected?)
    assert(set2.connected?)
    assert(set1.connected?)
    s[:f].disconnect
    assert(!path1.connected?)
    assert(!set2.connected?)
    assert(!set1.connected?)
  end

end
