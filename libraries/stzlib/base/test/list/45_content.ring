# Narrative
# --------
# ReplaceTheseItemsAtPositionsByManyXT: multi-value guard, palette CYCLED.
#
# At positions 1,3,4,5,7,8,9, replace any item that is one of [ "ring",
# "softanza" ] -- here every one of those positions qualifies -- and cycle
# the palette [ "♥", "♥♥" ] across all seven matches: ♥, ♥, ♥♥, ♥, ♥♥, ♥♥, ♥.
# Contrast block #43 (non-XT), which spreads the palette instead of cycling.
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
#--> [ "♥", "ruby", "♥", "♥♥", "♥", "php", "♥♥", "♥♥", "♥" ]

pf()
# Executed in almost 0 second(s)
