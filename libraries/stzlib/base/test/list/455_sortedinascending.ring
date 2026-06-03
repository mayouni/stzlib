# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #455.
#ERR Error (R14) : Calling Method without definition: sortedinascending

load "../../stzBase.ring"

pr()

o1 = new stzList([ 5, 7, 9, 2 ])
? o1.SortedInAscending()
#--> [ 2, 5, 7, 9 ]

pf()
# Executed in almost 0 second(s).
