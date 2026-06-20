# Narrative
# --------
# ReplaceAt (one or many positions) and ReplaceThisAt (guarded by value).
#
# ReplaceAt accepts a single position or a LIST of positions, setting each
# to the new item -- here positions 2 and 5 both become "♥". ReplaceThisAt
# is value-guarded: ReplaceThisAt(3, "♥", 3) replaces position 3 ONLY if it
# currently holds "♥", swapping it for 3. Both mutate in place.
#
# Extracted from stzlisttest.ring, block #532.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceAt([2, 5], "♥")	# Or ReplaceAnyAt()
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

o1.ReplaceThisAt(3, "♥", 3)
? @@( o1.Content() )
#--> [ "♥", "♥", 3, "♥", "♥" ]

pf()
# Executed in almost 0 second(s)
