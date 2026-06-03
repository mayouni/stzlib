# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #462.

load "../../stzBase.ring"


o1 = new stzList([ "a", "b", "c" ])

? o1.IsEqualTo([ "c", "b", "a" ])		#--> TRUE

? o1.IsStrictlyEqualTo([ "c", "b", "a" ])	#--> FALSE
# Because
? o1.HasSameTypeAs([ "c", "b", "a" ])		#--> TRUE
? o1.HasSameContentAs([ "c", "b", "a" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "c", "b", "a" ])	#--> FALSE

pf()
# Executed in 0.05 second(s).
