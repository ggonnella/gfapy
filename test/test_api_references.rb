require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::References < Test::Unit::TestCase

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
    # dovetails()
    assert_equal(sa.dovetails_R, sa.dovetails(:R))
    assert_equal(sa.dovetails_L, sa.dovetails(:L))
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
    assert_equal([], sa.dovetails(:L))
    assert_equal([], sa.dovetails(:R))
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
    # disconnection of segment cascades on edges
    g << lab
    assert(lab.connected?)
    assert_equal(sa, lab.sid1.line)
    sa.disconnect
    assert(!lab.connected?)
    assert_equal(:a, lab.sid1.line)
  end

  def test_edges_backreferences
    g = RGFA.new
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    s = {}
    {"0"=>0,"1"=>30,"2"=>70,"$"=>"100$".to_pos}.each do |sbeg1, beg1|
      {"0"=>0,"1"=>30,"2"=>70,"$"=>"100$".to_pos}.each do |send1, end1|
        next if beg1 > end1
        {"0"=>0,"1"=>30,"2"=>70,"$"=>"100$".to_pos}.each do |sbeg2, beg2|
          {"0"=>0,"1"=>30,"2"=>70,"$"=>"100$".to_pos}.each do |send2, end2|
            next if beg2 > end2
            [:+,:-].each do |or1|
              [:+,:-].each do |or2|
                eid = "<#{or1}#{or2}#{sbeg1}#{send1}#{sbeg2}#{send2}"
                other = "s#{eid}"
                g << ["E",eid,"a#{or1}","#{other}#{or2}",
                      beg1,end1,beg2,end2,"*"].join("\t")
                g << (s[other] = "S\t#{other}\t100\t*".to_rgfa_line)
                eid = ">#{or1}#{or2}#{sbeg1}#{send1}#{sbeg2}#{send2}"
                other = "s#{eid}"
                g << ["E",eid,"#{other}#{or1}","a#{or2}",
                      beg1,end1,beg2,end2,"*"].join("\t")
                g << (s[other] = "S\t#{other}\t100\t*".to_rgfa_line)
              end
            end
          end
        end
      end
    end
    exp_sa_d_L = []
    exp_sa_d_R = []
    exp_sa_e_cr = []
    exp_sa_e_cd = []
    exp_sa_i = []
    # a from 0 to non-$, other from non-0 to $;
    # same orientation; => d_L
    # opposite orientations; => internals
    ["0","1","2"].each do |e_a|
      ["1","2","$"].each do |b_other|
        ["++","--"].each do |ors|
          exp_sa_d_L << "<#{ors}0#{e_a}#{b_other}$".to_sym
          exp_sa_d_L << ">#{ors}#{b_other}$0#{e_a}".to_sym
        end
        ["+-","-+"].each do |ors|
          exp_sa_i << "<#{ors}0#{e_a}#{b_other}$".to_sym
          exp_sa_i << ">#{ors}#{b_other}$0#{e_a}".to_sym
        end
      end
    end
    # one from non-0 to non-$, other non-0 to non-$; => internals
    ["11","12","22"].each do |pos_one|
      ["11","12","22"].each do |pos_other|
        ["++","--","+-","-+"].each do |ors|
          ["<",">"].each do |d|
            exp_sa_i << "#{d}#{ors}#{pos_one}#{pos_other}".to_sym
          end
        end
      end
    end
    # one from non-0 to non-$, other 0 to non-$; => internals
    ["11","12","22"].each do |pos_one|
      ["00","01","02"].each do |pos_other|
        ["++","--","+-","-+"].each do |ors|
          ["<",">"].each do |d|
            exp_sa_i << "#{d}#{ors}#{pos_one}#{pos_other}".to_sym
            exp_sa_i << "#{d}#{ors}#{pos_other}#{pos_one}".to_sym
          end
        end
      end
    end
    # one from non-0 to non-$, other non-0 to $; => internals
    ["11","12","22"].each do |pos_one|
      ["1$","2$","$$"].each do |pos_other|
        ["++","--","+-","-+"].each do |ors|
          ["<",">"].each do |d|
            exp_sa_i << "#{d}#{ors}#{pos_one}#{pos_other}".to_sym
            exp_sa_i << "#{d}#{ors}#{pos_other}#{pos_one}".to_sym
          end
        end
      end
    end
    # other from 0 to non-$, a from non-0 to $
    # same orientation; => d_R
    # opposite orientations; => internals
    ["0","1","2"].each do |e_other|
      ["1","2","$"].each do |b_a|
        ["++","--"].each do |ors|
          exp_sa_d_R << "<#{ors}#{b_a}$0#{e_other}".to_sym
          exp_sa_d_R << ">#{ors}0#{e_other}#{b_a}$".to_sym
        end
        ["+-","-+"].each do |ors|
          exp_sa_i << "<#{ors}#{b_a}$0#{e_other}".to_sym
          exp_sa_i << ">#{ors}0#{e_other}#{b_a}$".to_sym
        end
      end
    end
    # both from 0 to non-$,
    # opposite orientations; => d_L
    # same orientation; => internals
    ["0","1","2"].each do |e1|
      ["0","1","2"].each do |e2|
        pos = "0#{e1}0#{e2}"
        ["+-","-+"].each do |ors|
          ["<",">"].each do |d|
            exp_sa_d_L << "#{d}#{ors}#{pos}".to_sym
          end
        end
        ["++","--"].each do |ors|
          ["<",">"].each do |d|
            exp_sa_i << "#{d}#{ors}#{pos}".to_sym
          end
        end
      end
    end
    # both from non-0 to $,
    # opposite orientations; => d_R
    # same orientation; => internals
    ["1","2","$"].each do |e1|
      ["1","2","$"].each do |e2|
        pos = "#{e1}$#{e2}$"
        ["+-","-+"].each do |ors|
          ["<",">"].each do |d|
            exp_sa_d_R << "#{d}#{ors}#{pos}".to_sym
          end
        end
        ["++","--"].each do |ors|
          ["<",">"].each do |d|
            exp_sa_i << "#{d}#{ors}#{pos}".to_sym
          end
        end
      end
    end
    # a whole; other non-whole => edges_to_containers
    ["00","01","02","11","12","1$","22","2$","$$"].each do |pos_other|
      ["++","--","+-","-+"].each do |ors|
        exp_sa_e_cr << "<#{ors}0$#{pos_other}".to_sym
        exp_sa_e_cr << ">#{ors}#{pos_other}0$".to_sym
      end
    end
    # a not-whole; other whole => edges_to_contained
    ["00","01","02","11","12","1$","22","2$","$$"].each do |pos_a|
      ["++","--","+-","-+"].each do |ors|
        exp_sa_e_cd << "<#{ors}#{pos_a}0$".to_sym
        exp_sa_e_cd << ">#{ors}0$#{pos_a}".to_sym
      end
    end
    # a sid1; both whole => edges_to_contained
    ["++","--","+-","-+"].each do |ors|
      exp_sa_e_cd << "<#{ors}0$0$".to_sym
    end
    # a sid2; both whole => edges_to_containers
    ["++","--","+-","-+"].each do |ors|
      exp_sa_e_cr << ">#{ors}0$0$".to_sym
    end
    # dovetails_[LR]
    assert_equal(exp_sa_d_L.sort,sa.dovetails_L.map(&:name).sort)
    assert_equal(exp_sa_d_R.sort,sa.dovetails_R.map(&:name).sort)
    # dovetails()
    assert_equal(sa.dovetails_L,sa.dovetails(:L))
    assert_equal(sa.dovetails_R,sa.dovetails(:R))
    assert_equal((sa.dovetails_L + sa.dovetails_R),sa.dovetails)
    # neighbours
    assert_equal((exp_sa_d_L+exp_sa_d_R).map{|eid|:"s#{eid}"}.sort,
                 sa.neighbours.map(&:name).sort)
    # edges_to_containers/contained
    assert_equal(exp_sa_e_cr.sort,sa.edges_to_containers.map(&:name).sort)
    assert_equal(exp_sa_e_cd.sort,sa.edges_to_contained.map(&:name).sort)
    # containments
    assert_equal((exp_sa_e_cr+exp_sa_e_cd).sort,
                 sa.containments.map(&:name).sort)
    # contained/containers
    assert_equal(exp_sa_e_cr.map{|eid|:"s#{eid}"}.sort,
                 sa.containers.map(&:name).sort)
    assert_equal(exp_sa_e_cd.map{|eid|:"s#{eid}"}.sort,
                 sa.contained.map(&:name).sort)
    # internals
    assert_equal(exp_sa_i.sort, sa.internals.map(&:name).sort)
    # upon disconnection
    sa.disconnect
    assert_equal([], sa.dovetails_L)
    assert_equal([], sa.dovetails_R)
    assert_equal([], sa.dovetails(:L))
    assert_equal([], sa.dovetails(:R))
    assert_equal([], sa.neighbours)
    assert_equal([], sa.edges_to_containers)
    assert_equal([], sa.edges_to_contained)
    assert_equal([], sa.containments)
    assert_equal([], sa.contained)
    assert_equal([], sa.containers)
    assert_equal([], sa.internals)
  end

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
    # disconnection of segment cascades on fragments
    g << f
    assert(f.connected?)
    assert_equal(sa, f.sid)
    sa.disconnect
    assert(!f.connected?)
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
    # disconnection effects
    f1.disconnect
    assert_equal([f2], sa.fragments)
    sa.disconnect
    assert_equal([], sa.fragments)
  end

  def test_gap_references
    g = RGFA.new
    gap = "G\t*\ta+\tb+\t90\t*".to_rgfa_line
    assert_equal(OL[:a,:+], gap.sid1)
    assert_equal(OL[:b,:+], gap.sid2)
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    g << (sb = "S\tb\t100\t*".to_rgfa_line)
    g << gap
    assert_equal(sa, gap.sid1.line)
    assert_equal(sb, gap.sid2.line)
    gap.disconnect
    assert_equal(:a, gap.sid1.line)
    assert_equal(:b, gap.sid2.line)
    # disconnection of segment cascades on gaps
    g << gap
    assert(gap.connected?)
    assert_equal(sa, gap.sid1.line)
    sa.disconnect
    assert(!gap.connected?)
    assert_equal(:a, gap.sid1.line)
  end

  def test_gaps_backreferences
    g = RGFA.new
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    # gaps
    s = {}; gap = {}
    [:b, :c, :d, :e, :f, :g, :h, :i].each do |name|
      g << (s[name] = "S\t#{name}\t*".to_rgfa_line)
    end
    ["a+b+", "a+c-", "a-d+", "a-e-",
     "f+a+", "g+a-", "h-a+", "i-a-"].each do |name|
      g << (gap[name] =
            ["G","*",name[0..1],name[2..3],200,"*"].join("\t").to_rgfa_line)
    end
    # gaps_[LR]()
    assert_equal([gap["a-d+"], gap["a-e-"], gap["f+a+"], gap["h-a+"]],
                 sa.gaps_L)
    assert_equal([gap["a+b+"], gap["a+c-"], gap["g+a-"], gap["i-a-"]],
                 sa.gaps_R)
    # gaps()
    assert_equal(sa.gaps_L, sa.gaps(:L))
    assert_equal(sa.gaps_R, sa.gaps(:R))
    assert_equal(sa.gaps_L + sa.gaps_R, sa.gaps)
    # disconnection effects
    gap["a-d+"].disconnect
    assert_equal([gap["a-e-"], gap["f+a+"], gap["h-a+"]], sa.gaps_L)
    sa.disconnect
    assert_equal([], sa.gaps_L)
    assert_equal([], sa.gaps_R)
    assert_equal([], sa.gaps(:L))
    assert_equal([], sa.gaps(:R))
    assert_equal([], sa.gaps)
  end

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
    # disconnection effects
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

  def test_unordered_groups_references
  end

  def test_ordered_groups_references
  end

  def test_reference_fields_editing
  end

end
