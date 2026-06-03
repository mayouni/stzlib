# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #443.
#ERR Error (R14) : Calling Method without definition: findnextoccurrencesst

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A" , "B", "A", "C", "A", "D", "A" ])

? o1.FindNextOccurrencesST("A", 3)
#--> [ 5, 7 ]

? o1.FindNextNthOccurrencesST([1, 2], "A", 3)
#--> [ 5, 7 ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
