# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #45.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceTheseItemsAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	[ "ring", "softanza" ], [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#       1    2       3     4    5     6      7    8     9
#--> [ "♥", "ruby", "♥", "♥♥", "♥", "php", "♥♥", "♥♥", "♥" ]
#	^                  ^    ^                 ^
#                    ^                       ^          ^

pf()
# Executed in 0.06 second(s)
