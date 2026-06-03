# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #364.
#ERR Error (R14) : Calling Method without definition: antisections

load "../../stzBase.ring"

pr()

o1 = new stzString("...ONE...TWO...ONE")

? o1.Sections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])
#--> [ "ONE", "TWO", "THREE"

? o1.AntiSections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])
#--> [ "...", "...", "..." ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18
