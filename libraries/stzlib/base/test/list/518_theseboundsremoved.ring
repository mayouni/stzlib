# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #518.
#ERR Error (R14) : Calling Method without definition: theseboundsremoved

load "../../stzBase.ring"

pr()

o1 = new stzList([ "{", "A", "B", "C", "}" ])

? o1.TheseBoundsRemoved("{", "}")
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.01 second(s).
