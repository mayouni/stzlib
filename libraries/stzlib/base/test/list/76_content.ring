# Narrative
# --------
# ReplaceOccurrencesByMany: replace the items at the listed positions, one
# replacement per position (1-to-1).
#
# Positions 3,5,6 receive "C","E","F" in order, filling in the placeholder
# "*"/"=" slots to spell out [ "A","B","C","D","E","F" ]. The palette length
# matches the position count, so each lands once. (The XT twin, block #77,
# cycles a shorter palette instead.)
#
# Extracted from stzlisttest.ring, block #76.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "*", "D", "*",  "=" ])

o1.ReplaceOccurrencesByMany([ 3, 5, 6 ], ["C", "E", "F"])

? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

pf()
# Executed in 0.06 second(s)
