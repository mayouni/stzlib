# Narrative
# --------
# ReplaceItemAtPositionsByManyXT with a 2-colour palette over the "ring"
# positions.
#
# Among positions 1,3,4,5,7,8,9, only the "ring" items are replaced and the
# palette [ "♥", "♥♥" ] cycles across those matches: the "ring"s at 1,4,5,8
# become ♥, ♥♥, ♥, ♥♥ in turn, while the "softanza" slots (3,7,9) are left
# alone.
#
# Extracted from stzlisttest.ring, block #44.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceItemAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	"ring" , [ "♥", "♥♥" ] )

? @@( o1.Content() )
#--> [ "♥", "ruby", "softanza", "♥♥", "♥", "php", "softanza", "♥♥", "softanza" ]

pf()
# Executed in almost 0 second(s)
