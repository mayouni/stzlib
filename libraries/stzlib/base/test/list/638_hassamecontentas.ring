# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #638.
#ERR Error (R14) : Calling Method without definition: hassamecontentas

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "c", 12 ])
? o1.HasSameContentAs([ "a", 12, "c" ])
#--> TRUE

pf()
# Executed in almost 0 second(s).
