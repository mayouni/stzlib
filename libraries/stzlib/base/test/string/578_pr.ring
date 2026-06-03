# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #578.

load "../../stzBase.ring"


o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

o1.RemoveAnySubStringBoundedByIB([ "<<", ">>" ])
? o1.Content()
#--> bla bla  bla bla  bla 

pf()
# Executed in 0.06 second(s) in Ring 1.22
