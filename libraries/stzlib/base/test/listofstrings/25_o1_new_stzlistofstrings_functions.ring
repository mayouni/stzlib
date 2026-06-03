# Narrative
# --------
# o1 = new stzListOfStrings( functions() )
#
# Extracted from stzlistofstringstest.ring, block #25.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.ContainsCS("StzRaise", :CS = FALSE)	#--> TRUE
? o1.FindFirstcs("StzRaise", :CS = FALSE)	#--> 318

pf()
