# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #457.
#ERR Error (R14) : Calling Method without definition: hassamecontentas

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])

? o1.IsStrictlyEqualTo([ "a", "b", "c" ])	#--> TRUE

# Because
? o1.HasSameTypeAs([ "a", "b", "c" ])		#--> TRUE
? o1.HasSameContentAs([ "a", "b", "c" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "a", "b", "c" ])	#--> TRUE

pf()
# Executed in 0.04 second(s).
