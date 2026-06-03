# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #574.

load "../../stzBase.ring"


o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

o1.ReplaceSubStringBoundedBy("noword", [ "<<", ">>" ], :With = "word")
? o1.Content() + NL
#--> bla bla <<word>> bla bla <<word>> bla <<word>>

# or, more naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.ReplaceXT("noword", :BoundedBy = ["<<", ">>"], :With = "word")
? o1.Content()
#--> bla bla <<word>> bla bla <<word>> bla <<word>>

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.19
