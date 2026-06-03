# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #528.

load "../../stzBase.ring"


o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.SubstringsBoundedBy([ "<<", :and = ">>" ])
#--> [ "word", "noword", "word" ]

? o1.SubStringsBoundedByU([ "<<", :and = ">>" ]) # Or UniqueSubStringsBoundedBy()
#--> [ "word", "noword" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
