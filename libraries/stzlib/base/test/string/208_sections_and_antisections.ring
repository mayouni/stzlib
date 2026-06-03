# Narrative
# --------
# Sections and AntiSections
#
# Extracted from stzStringTest.ring, block #208.
#ERR Error (R14) : Calling Method without definition: antisections

load "../../stzBase.ring"


pr()

o1 = new stzString("...456...012...")

? o1.Sections([ [4, 6], [10, 12] ])
#--> [ "456", "012" ]

? o1.AntiSections([ [4, 6], [10, 12] ])
#--> [ "...", "...", "..." ]

? @@( o1.FindAsSections([ "456", "012" ]) )
#--> [ [ 4, 6 ], [ 10, 12 ] ]

? @@( o1.AntiFindAsSections([ "456", "012" ]) )
#--> [ [ 1, 3 ], [ 7, 9 ], [ 13, 15 ] ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.20 second(s) in Ring 1.18
