# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #520.
#ERR Error (R14) : Calling Method without definition: eachitemexistsin

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])

? o1.EachItemExistsIn([ "1", "2", "A", "B", "C", "3", "4" ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
