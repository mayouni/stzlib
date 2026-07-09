# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #591.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])

? o1.ContainsNo("v")
#--> TRUE

? o1.ContainsNoObjects()
#--> TRUE

pf()
# Executed in almost 0 second(s).
