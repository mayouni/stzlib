# Narrative
# --------
# pr()
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
#	^                        ^    ^                        ^

pf()
# Executed in 0.04 second(s)
