import gfapy
import unittest

class TestAPIReferencesEdgesGFA2(unittest.TestCase):

  def test_edges_references(self):
    g = gfapy.Gfa()
    lab = gfapy.Line("E\t*\ta+\tb+\t0\t10\t90\t100$\t*")
    self.assertEqual(gfapy.OrientedLine("a","+"), lab.sid1)
    self.assertEqual(gfapy.OrientedLine("b","+"), lab.sid2)
    sa = gfapy.Line("S\ta\t100\t*")
    g.append(sa)
    sb = gfapy.Line("S\tb\t100\t*")
    g.append(sb)
    g.append(lab)
    self.assertEqual(sa, lab.sid1.line)
    self.assertEqual(sb, lab.sid2.line)
    lab.disconnect()
    self.assertEqual("a", lab.sid1.line)
    self.assertEqual("b", lab.sid2.line)
    # disconnection of segment cascades on edges
    g.append(lab)
    assert(lab.is_connected())
    self.assertEqual(sa, lab.sid1.line)
    sa.disconnect()
    assert(not lab.is_connected())
    self.assertEqual("a", lab.sid1.line)

  def test_edges_backreferences(self):
    g = gfapy.Gfa()
    sa = gfapy.Line("S\ta\t100\t*")
    g.append(sa)
    s = {}
    for sbeg1, beg1 in {"0":0,"1":30,"2":70,"$":gfapy.LastPos("100$")}.items():
      for send1, end1 in {"0":0,"1":30,"2":70,"$":gfapy.LastPos("100$")}.items():
        if beg1 > end1:
          continue
        for sbeg2, beg2 in {"0":0,"1":30,"2":70,"$":gfapy.LastPos("100$")}.items():
          for send2, end2 in {"0":0,"1":30,"2":70,"$":gfapy.LastPos("100$")}.items():
            if beg2 > end2:
              continue
            for or1 in ["+","-"]:
              for or2 in ["+","-"]:
                eid = "<{}".format(or1)+"{}".format(or2)+"{}".format(sbeg1)+"{}".format(send1)+"{}".format(sbeg2)+"{}".format(send2)
                other = "s{}".format(eid)
                g.append("\t".join(["E",eid,"a{}".format(or1),"{}".format(other)+"{}".format(or2),
                                    str(beg1),str(end1),str(beg2),str(end2),"*"]))
                s[other] = gfapy.Line("S\t{}".format(other)+"\t100\t*")
                g.append(s[other])
                eid = ">{}".format(or1)+"{}".format(or2)+"{}".format(sbeg1)+"{}".format(send1)+"{}".format(sbeg2)+"{}".format(send2)
                other = "s{}".format(eid)
                g.append("\t".join(["E",eid,"{}".format(other)+"{}".format(or1),"a{}".format(or2),
                                    str(beg1),str(end1),str(beg2),str(end2),"*"]))
                s[other] = gfapy.Line("S\t{}".format(other)+"\t100\t*")
                g.append(s[other])
    exp_sa_d_L = []
    exp_sa_d_R = []
    exp_sa_e_cr = []
    exp_sa_e_cd = []
    exp_sa_i = []
    # a from 0 to non-$, other from non-0 to $;
    # same orientation;"d_L"
    # opposite orientations;"internals"
    for e_a in ["0","1","2"]:
      for b_other in ["1","2","$"]:
        for ors in ["++","--"]:
          exp_sa_d_L.append("<{}".format(ors)+"0{}".format(e_a)+"{}".format(b_other)+"$")
          exp_sa_d_L.append(">{}".format(ors)+"{}".format(b_other)+"$0{}".format(e_a))
        for ors in ["+-","-+"]:
          exp_sa_i.append("<{}".format(ors)+"0{}".format(e_a)+"{}".format(b_other)+"$")
          exp_sa_i.append(">{}".format(ors)+"{}".format(b_other)+"$0{}".format(e_a))
    # one from non-0 to non-$, other non-0 to non-$;"internals"
    for pos_one in ["11","12","22"]:
      for pos_other in ["11","12","22"]:
        for ors in ["++","--","+-","-+"]:
          for d in ["<",">"]:
            exp_sa_i.append("{}".format(d)+"{}".format(ors)+"{}".format(pos_one)+"{}".format(pos_other))
    # one from non-0 to non-$, other 0 to non-$;"internals"
    for pos_one in ["11","12","22"]:
      for pos_other in ["00","01","02"]:
        for ors in ["++","--","+-","-+"]:
          for d in ["<",">"]:
            exp_sa_i.append("{}".format(d)+"{}".format(ors)+"{}".format(pos_one)+"{}".format(pos_other))
            exp_sa_i.append("{}".format(d)+"{}".format(ors)+"{}".format(pos_other)+"{}".format(pos_one))
    # one from non-0 to non-$, other non-0 to $;"internals"
    for pos_one in ["11","12","22"]:
      for pos_other in ["1$","2$","$$"]:
        for ors in ["++","--","+-","-+"]:
          for d in ["<",">"]:
            exp_sa_i.append("{}".format(d)+"{}".format(ors)+"{}".format(pos_one)+"{}".format(pos_other))
            exp_sa_i.append("{}".format(d)+"{}".format(ors)+"{}".format(pos_other)+"{}".format(pos_one))
    # other from 0 to non-$, a from non-0 to $
    # same orientation;"d_R"
    # opposite orientations;"internals"
    for e_other in ["0","1","2"]:
      for b_a in ["1","2","$"]:
        for ors in ["++","--"]:
          exp_sa_d_R.append("<"+"{}".format(ors)+"{}".format(b_a)+"$0"+"{}".format(e_other))
          exp_sa_d_R.append(">"+"{}".format(ors)+"0"+"{}".format(e_other)+"{}".format(b_a)+"$")
        for ors in ["+-","-+"]:
          exp_sa_i.append("<"+"{}".format(ors)+"{}".format(b_a)+"$0"+"{}".format(e_other))
          exp_sa_i.append(">"+"{}".format(ors)+"0"+"{}".format(e_other)+"{}".format(b_a)+"$")
    # both from 0 to non-$,
    # opposite orientations;"d_L"
    # same orientation;"internals"
    for e1 in ["0","1","2"]:
      for e2 in ["0","1","2"]:
        pos = "0"+"{}".format(e1)+"0"+"{}".format(e2)
        for ors in ["+-","-+"]:
          for d in ["<",">"]:
            exp_sa_d_L.append("{}".format(d)+"{}".format(ors)+"{}".format(pos))
        for ors in ["++","--"]:
          for d in ["<",">"]:
            exp_sa_i.append("{}".format(d)+"{}".format(ors)+"{}".format(pos))
    # both from non-0 to $,
    # opposite orientations;"d_R"
    # same orientation;"internals"
    for e1 in ["1","2","$"]:
      for e2 in ["1","2","$"]:
        pos = "{}".format(e1)+"$"+"{}".format(e2)+"$"
        for ors in ["+-","-+"]:
          for d in ["<",">"]:
            exp_sa_d_R.append("{}".format(d)+"{}".format(ors)+"{}".format(pos))
        for ors in ["++","--"]:
          for d in ["<",">"]:
            exp_sa_i.append("{}".format(d)+"{}".format(ors)+"{}".format(pos))
    # a whole; other non-whole:edges_to_containers
    for pos_other in ["00","01","02","11","12","1$","22","2$","$$"]:
      for ors in ["++","--","+-","-+"]:
        exp_sa_e_cr.append("<{}".format(ors)+"0${}".format(pos_other))
        exp_sa_e_cr.append(">{}".format(ors)+"{}".format(pos_other)+"0$")
    # a not-whole; other whole:edges_to_contained
    for pos_a in ["00","01","02","11","12","1$","22","2$","$$"]:
      for ors in ["++","--","+-","-+"]:
        exp_sa_e_cd.append("<{}".format(ors)+"{}".format(pos_a)+"0$")
        exp_sa_e_cd.append(">{}".format(ors)+"0${}".format(pos_a))
    # a sid1; both whole:edges_to_contained
    for ors in ["++","--","+-","-+"]:
      exp_sa_e_cd.append("<{}".format(ors)+"0$0$")
    # a sid2; both whole:edges_to_containers
    for ors in ["++","--","+-","-+"]:
      exp_sa_e_cr.append(">{}".format(ors)+"0$0$")
    # dovetails_[LR]
    self.assertEqual(set(exp_sa_d_L), set([x.name for x in sa.dovetails_L]))
    self.assertEqual(set(exp_sa_d_R), set([x.name for x in sa.dovetails_R]))
    # dovetails()
    self.assertEqual(sa.dovetails_L, sa.dovetails_of_end("L"))
    self.assertEqual(sa.dovetails_R, sa.dovetails_of_end("R"))
    self.assertEqual((sa.dovetails_L + sa.dovetails_R), sa.dovetails)
    # neighbours
    self.assertEqual(set(["s"+x for x in (exp_sa_d_L+exp_sa_d_R)]),
                     set([x.name for x in sa.neighbours]))
    # edges_to_containers/contained
    self.assertEqual(set(exp_sa_e_cr),
                     set([x.name for x in sa.edges_to_containers]))
    self.assertEqual(set(exp_sa_e_cd),
                     set([x.name for x in sa.edges_to_contained]))
    # containments
    self.assertEqual(set(exp_sa_e_cr+exp_sa_e_cd),
                 set([x.name for x in sa.containments]))
    # contained/containers
    self.assertEqual(set(["s"+x for x in exp_sa_e_cr]),
                     set([x.name for x in sa.containers]))
    self.assertEqual(set(["s"+x for x in exp_sa_e_cd]),
                     set([x.name for x in sa.contained]))
    # internals
    self.assertEqual(set(exp_sa_i), set([x.name for x in sa.internals]))
    # upon disconnection
    sa.disconnect()
    self.assertEqual([], sa.dovetails_L)
    self.assertEqual([], sa.dovetails_R)
    self.assertEqual([], sa.dovetails_of_end("L"))
    self.assertEqual([], sa.dovetails_of_end("R"))
    self.assertEqual([], sa.neighbours)
    self.assertEqual([], sa.edges_to_containers)
    self.assertEqual([], sa.edges_to_contained)
    self.assertEqual([], sa.containments)
    self.assertEqual([], sa.contained)
    self.assertEqual([], sa.containers)
    self.assertEqual([], sa.internals)

