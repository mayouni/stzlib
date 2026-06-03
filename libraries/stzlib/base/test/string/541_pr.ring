# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #541.

load "../../stzBase.ring"


o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")

? o1.FindNthBoundedBy(2, "word", [ "<<", ">>" ]) + NL
#--> 28

? o1.FindNthBoundedByZZ(2, "word", [ "<<", ">>" ])
#--> [28, 31]

? o1.FindNthXT(2, "word", :BoundedBy = ["<<", ">>"]) + NL
#--> 28

# TODO
# ? o1.FindNthXTZZ(2, "word", :BoundedBy = ["<<", ">>"])

pf()
# Executed in 0.01 second(s) in Ring 1.22
