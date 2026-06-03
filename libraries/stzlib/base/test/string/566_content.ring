# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #566.

load "../../stzBase.ring"

pr()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")

o1.ReplaceSubStringsBoundedBy([ "<<", ">>" ], "wrod")
? o1.Content()
#--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

pf()
# Executed in 0.04 second(s) in Ring 1.22
