# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #73.
#ERR Error (R14) : Calling Method without definition: addxt

load "../../stzBase.ring"

pr()

o1 = new stzString("we loveringlanguage!")
o1.AddXT([ " ", " " ], :Around = "ring")

? o1.Content()
# Executed in 0.04 second(s)

pf()
