# Narrative
# --------
# ReplaceAnyItemsAtPositionsByManyXT: plural "Items", no value guard, palette
# CYCLED across every listed position.
#
# At positions 1,3,4,5,7,8 -- whatever they currently hold -- the palette
# [ "♥", "♥♥" ] is applied in a repeating cycle: ♥, ♥♥, ♥, ♥♥, ♥, ♥♥. Position
# 6 ("php") and 9 ("python") are left alone. "Any" drops the value guard;
# "XT" recycles the (shorter) palette.
#
# Extracted from stzlisttest.ring, block #46.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"ring", "ruby", "softanza", "ring", "softanza", "php", "softanza", "ring", "python"
])

o1.ReplaceAnyItemsAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8 ], [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#--> [ "♥", "ruby", "♥♥", "♥", "♥♥", "php", "♥", "♥♥", "python" ]

pf()
# Executed in 0.03 second(s)
