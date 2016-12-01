require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::ReferencesEdges < Test::Unit::TestCase

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

end
