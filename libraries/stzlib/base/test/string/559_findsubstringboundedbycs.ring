# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #559.
#ERR Error (R14) : Calling Method without definition: findsubstringboundedbycs

load "../../stzBase.ring"

pr()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindSubStringBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = FALSE)
#--> [ 11, 43 ]

? o1.FindSubStringBoundedByAsSections("word", [ "<<", ">>" ])
#--> [ [11, 14], [43, 46] ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
