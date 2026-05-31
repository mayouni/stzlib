# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #43.

load "../../../stzBase.ring"


o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
o1.ReplaceTheseItemsAtPositionsByMany([ 1, 3, 4, 6 ], [ "ring", "softanza" ] , [ "♥", "♥♥" ])
		
? @@( o1.Content() )
#--> [ "♥", "ruby", "♥", "♥♥", "php", "♥♥" ]

pf()
# Executed in 0.06 second(s)
