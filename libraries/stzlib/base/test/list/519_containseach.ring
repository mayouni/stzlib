# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #519.
#ERR Error (R14) : Calling Method without definition: containseachoneofthese

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "A", "B", "C", "3", "4" ])

? o1.ContainsEach([ "A", "B", "C" ])
#--> TRUE

? o1.ContainsEachOneOfThese([ "A", "B", "C" ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
