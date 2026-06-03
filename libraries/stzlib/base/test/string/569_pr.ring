# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #569.

load "../../stzBase.ring"


o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")

o1.RemoveBoundedSubString("word")
? o1.Content()
#--> bla  bla <<>> bla bla <<>> bla <<>> word

pf()
# Executed in 0.05 second(s) in Ring 1.22
