require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::References < Test::Unit::TestCase

  def test_links_references
    g = RGFA.new
    lab = "L\ta\t+\tb\t+\t*".to_rgfa_line
    assert_equal(:a, lab.from)
    assert_equal(:b, lab.to)
    g << (sa = "S\ta\t*".to_rgfa_line)
    g << (sb = "S\tb\t*".to_rgfa_line)
    g << lab
    assert_equal(sa, lab.from)
    assert_equal(sb, lab.to)
    lab.disconnect
    assert_equal(:a, lab.from)
    assert_equal(:b, lab.to)
  end

  def test_links_backreferences
    g = RGFA.new
    g << (sa = "S\ta\t*".to_rgfa_line)
    # links
    s = {}; l = {}
    [:b, :c, :d, :e, :f, :g, :h, :i].each do |name|
      g << (s[name] = "S\t#{name}\t*".to_rgfa_line)
    end
    ["a+b+", "a+c-", "a-d+", "a-e-",
     "f+a+", "g+a-", "h-a+", "i-a-"].each do |name|
      g << (l[name] = name.chars.unshift("L").push("*").join("\t").to_rgfa_line)
    end
    # dovetails_[LR]()
    assert_equal([l["a+b+"], l["a+c-"],
                  l["g+a-"], l["i-a-"]], sa.dovetails_R)
    assert_equal([l["a-d+"], l["a-e-"],
                  l["f+a+"], l["h-a+"]], sa.dovetails_L)
    # dovetails()
    assert_equal(sa.dovetails_R, sa.dovetails(:R))
    assert_equal(sa.dovetails_L, sa.dovetails(:L))
    assert_equal(sa.dovetails_L + sa.dovetails_R, sa.dovetails)
    # neighbours
    assert_equal([:b, :c, :d, :e, :f, :g, :h, :i].sort,
                 sa.neighbours.map(&:name).sort)
    # also when there are links,
    # gfa2 specific collections are empty in gfa1
    assert_equal([], sa.gaps)
    assert_equal([], sa.fragments)
    assert_equal([], sa.internals)
  end

  def test_containments_references
    g = RGFA.new
    cab = "C\ta\t+\tb\t+\t10\t*".to_rgfa_line
    assert_equal(:a, cab.from)
    assert_equal(:b, cab.to)
    g << (sa = "S\ta\t*".to_rgfa_line)
    g << (sb = "S\tb\t*".to_rgfa_line)
    g << cab
    assert_equal(sa, cab.from)
    assert_equal(sb, cab.to)
    cab.disconnect
    assert_equal(:a, cab.from)
    assert_equal(:b, cab.to)
  end

  def test_containments_backreferences
    g = RGFA.new
    g << (sa = "S\ta\t*".to_rgfa_line)
    # containments:
    s = {}; c = {}
    [:b, :c, :d, :e, :f, :g, :h, :i].each do |name|
      g << (s[name] = "S\t#{name}\t*".to_rgfa_line)
    end
    ["a+b+", "a+c-", "a-d+", "a-e-",
     "f+a+", "g+a-", "h-a+", "i-a-"].each do |name|
      g << (c[name] = (["C"]+name.chars+["10","*"]).join("\t").to_rgfa_line)
    end
    # edges to contained/containers
    assert_equal([c["a+b+"], c["a+c-"],
                  c["a-d+"], c["a-e-"]], sa.edges_to_contained)
    assert_equal([c["f+a+"], c["g+a-"],
                  c["h-a+"], c["i-a-"]], sa.edges_to_containers)
    # containments
    assert_equal(sa.edges_to_contained + sa.edges_to_containers,
                 sa.containments)
    # contained/containers
    assert_equal([s[:b], s[:c], s[:d], s[:e]], sa.contained)
    assert_equal([s[:f], s[:g], s[:h], s[:i]], sa.containers)
    # also when there are containments,
    # gfa2 specific collections are empty in gfa1
    assert_equal([], sa.gaps)
    assert_equal([], sa.fragments)
    assert_equal([], sa.internals)
  end

  def test_edges_references
    g = RGFA.new
    lab = "E\t*\ta+\tb+\t0\t10\t90\t100$\t*".to_rgfa_line
    assert_equal(OL[:a,:+], lab.sid1)
    assert_equal(OL[:b,:+], lab.sid2)
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    g << (sb = "S\tb\t100\t*".to_rgfa_line)
    g << lab
    assert_equal(sa, lab.sid1.line)
    assert_equal(sb, lab.sid2.line)
    lab.disconnect
    assert_equal(:a, lab.sid1.line)
    assert_equal(:b, lab.sid2.line)
  end

  # TODO: test_edges_backreferences (internals, containments, links)

  def test_fragments_references
    g = RGFA.new
    f = "F\ta\tf+\t0\t200\t281\t502$\t*".to_rgfa_line
    assert_equal(:a, f.sid)
    assert_equal(OL[:f,:+], f.external)
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    g << f
    assert_equal(sa, f.sid)
    f.disconnect
    assert_equal(:a, f.sid)
  end

  def test_fragments_backreferences
    g = RGFA.new
    f1 = "F\ta\tf+\t0\t200\t281\t502$\t*".to_rgfa_line
    f2 = "F\ta\tf+\t240\t440$\t0\t210\t*".to_rgfa_line
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    g << f1
    g << f2
    assert_equal([f1,f2], sa.fragments)
  end

  def test_gaps_references_groups
  end

  def test_paths_references
  end

  def test_unordered_groups_references
  end

  def test_ordered_groups_references
  end

  def test_reference_fields_editing
  end

end
