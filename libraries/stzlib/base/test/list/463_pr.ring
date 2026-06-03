# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #463.

load "../../stzBase.ring"


o1 = new stzList([ "a", "b", "c" ])
? o1.IsStrictlyEqualTo([ "a", "b" ])	#--> FALSE

# Because
? o1.HasSameTypeAs([ "a", "b" ])		#--> TRUE
? o1.IsEqualTo([ "a", "b" ])			#--> FALSE
? o1.HasSameSortingOrderAs([ "a", "b" ])#--> TRUE

pf()
# Executed in almost 0 second(s).
