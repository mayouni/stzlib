# Narrative
# --------
# ReplaceSubStringBoundedIB
#
# Extracted from stzStringTest.ring, block #576.

load "../../stzBase.ring"


pr()

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")

o1.ReplaceSubStringBoundedByIB("word", [ "<<", ">>" ], "WORD")
? o1.Content() + NL
#--> bla bla WORD bla bla WORD bla WORD.

# or, more naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")

o1.ReplaceXT("word", :BoundedByIB = ["<<", ">>"], :With = "WORD")
? o1.Content()
#--> bla bla WORD bla bla WORD bla WORD.

pf()
# Executed in 0.08 second(s) in Ring 1.22
