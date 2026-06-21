# Narrative
# --------
# ReplaceByMany: replace successive occurrences of one item with successive
# palette entries (1-to-1, in order).
#
# "ring" occurs three times (positions 1,4,6); the palette
# [ "♥", "♥♥", "♥♥♥" ] is consumed one entry per occurrence -- first ring->♥,
# second ring->♥♥, third ring->♥♥♥. Unlike the "XT" position variants this
# does NOT cycle; it pairs the palette to occurrences left-to-right.
#
# Extracted from stzlisttest.ring, block #53.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "php", "ruby", "ring", "python", "ring" ])
o1.ReplaceByMany("ring", [ "♥", "♥♥", "♥♥♥" ])
	
? o1.Content()
#--> [ "♥", "php", "ruby", "♥♥", "python", "♥♥♥" ]

pf()
# Executed in 0.03 second(s)
