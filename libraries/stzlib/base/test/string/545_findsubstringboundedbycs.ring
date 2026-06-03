# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #545.

load "../../stzBase.ring"

pr()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

? o1.FindSubStringBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = FALSE)
#--> [ 11, 43 ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
