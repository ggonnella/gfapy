require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::ReferencesEdgesGFA1 < Test::Unit::TestCase

  def test_links_references
    g = RGFA.new
    lab = "L\ta\t+\tb\t+\t*".to_rgfa_line
    assert_equal(:a, lab.from)
    assert_equal(:b, lab.to)
    g << lab
    g << (sa = "S\ta\t*".to_rgfa_line)
    g << (sb = "S\tb\t*".to_rgfa_line)
    assert_equal(sa, lab.from)
    assert_equal(sb, lab.to)
    lab.disconnect
    assert_equal(:a, lab.from)
    assert_equal(:b, lab.to)
    # disconnection of segment cascades on links
    g << lab
    assert(lab.connected?)
    assert_equal(sa, lab.from)
    sa.disconnect
    assert(!lab.connected?)
    assert_equal(:a, lab.from)
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
    # dovetails_of_end()
    assert_equal(sa.dovetails_R, sa.dovetails_of_end(:R))
    assert_equal(sa.dovetails_L, sa.dovetails_of_end(:L))
    assert_equal(sa.dovetails_L + sa.dovetails_R, sa.dovetails)
    # neighbours
    assert_equal([:b, :c, :d, :e, :f, :g, :h, :i].sort,
                 sa.neighbours.map(&:name).sort)
    # gfa2 specific collections are empty in gfa1
    assert_equal([], sa.gaps)
    assert_equal([], sa.fragments)
    assert_equal([], sa.internals)
    # upon disconnection
    sa.disconnect
    assert_equal([], sa.dovetails_R)
    assert_equal([], sa.dovetails_R)
    assert_equal([], sa.dovetails_of_end(:L))
    assert_equal([], sa.dovetails_of_end(:R))
    assert_equal([], sa.dovetails)
    assert_equal([], sa.neighbours)
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
    # disconnection of segment cascades on containments
    g << cab
    assert(cab.connected?)
    assert_equal(sa, cab.from)
    sa.disconnect
    assert(!cab.connected?)
    assert_equal(:a, cab.from)
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
    # gfa2 specific collections are empty in gfa1
    assert_equal([], sa.gaps)
    assert_equal([], sa.fragments)
    assert_equal([], sa.internals)
    # upon disconnection
    sa.disconnect
    assert_equal([], sa.edges_to_contained)
    assert_equal([], sa.edges_to_containers)
    assert_equal([], sa.containments)
    assert_equal([], sa.contained)
    assert_equal([], sa.containers)
  end

end
