# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #638.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "c", 12 ])
? o1.HasSameContentAs([ "a", 12, "c" ])
#--> TRUE

pf()
# Executed in almost 0 second(s).
