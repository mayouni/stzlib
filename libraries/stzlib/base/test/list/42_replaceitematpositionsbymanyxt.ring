# Narrative
# --------
# ReplaceItemAtPositionsByManyXT with a 3-colour palette over 7 positions.
#
# Among positions 1,3,4,5,7,8,9, only those holding "ring" are replaced; the
# 3-item palette [ "♥", "♥♥", "♥♥♥" ] cycles across the matches. Positions 3
# and 7 hold "softanza" (not "ring") so they're left untouched, and the ♥
# cycle advances only on the actual "ring" hits.
#
# Extracted from stzlisttest.ring, block #42.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceItemAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	"ring" , [ "♥", "♥♥", "♥♥♥" ] )

? @@( o1.Content() )
#--> [ "♥", "ruby", "softanza", "♥♥", "♥♥♥", "php", "softanza", "♥", "softanza" ]

pf()
# Executed in almost 0 second(s)
