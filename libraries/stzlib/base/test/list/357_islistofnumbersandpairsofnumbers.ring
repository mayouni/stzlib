# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #357.
#ERR Error (R14) : Calling Method without definition: islistofnumbersandpairsofnumbers

load "../../stzBase.ring"

pr()

o1 = new stzList([ 0, 2, 0, 3, [1,2] ])
? o1.IsListOfNumbersAndPairsOfNumbers()
#--> TRUE

pf()
# Executed in almost 0 second(s).
