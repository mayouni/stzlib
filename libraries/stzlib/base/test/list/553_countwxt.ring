# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #553.
#ERR Error (R14) : Calling Method without definition: countwxt

load "../../stzBase.ring"

pr()

o1 = new stzList(["c", "c++", "C#", "RING", "python", "ruby"])

//? o1.FindW("   ")
#--> ERROR: Can't proceed.

? o1.CountWXT('{ IsLowercase(@item) }')
#--> 4

? o1.NumberOfOccurrenceWXT('{ IsLowercase(@item) }') #--> 6
#--> 4

pf()
# Executed in 0.25 second(s).
