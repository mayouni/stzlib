# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #540.

load "../../stzBase.ring"

pr()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

? o1.Nth(2, "word") + NL
#--> 30

? @@( o1.NthAsSection(2, "word") )
#--> [ 30, 33 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
