# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #571.
#ERR Error (R14) : Calling Method without definition: sortup

load "../../stzBase.ring"

pr()

o1 = new stzList([ 5, 4, 3, 7 ])
o1.SortUp() # Or SortInAscending()
? o1.Content()
#--| [ 3, 4, 5, 7 ]

pf()
# Executed in almost 0 second(s).
