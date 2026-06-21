# Narrative
# --------
# ReplaceItemAtPositionsByManyXT: value-guarded replacement at given
# positions, CYCLING a shorter palette.
#
# At positions 3,5,7,9 -- only where the item is "ring" (all are) -- the two
# replacements [ "♥", "♥♥" ] are applied in a repeating cycle: ♥, ♥♥, ♥, ♥♥.
# ("XT" = recycle the palette; the value guard "ring" skips non-matching
# positions.)
#
# Extracted from stzlisttest.ring, block #39.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByManyXT([ 3, 5, 7, 9], "ring", [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

pf()
# Executed in almost 0 second(s)
