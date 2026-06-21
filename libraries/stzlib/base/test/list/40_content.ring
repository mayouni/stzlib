# Narrative
# --------
# ReplaceAnyItemAtPositionsByManyXT: replace WHATEVER is at the given
# positions, cycling a shorter palette.
#
# Like block #39 but WITHOUT the value guard -- "Any" means the item's
# current value is irrelevant. Positions 3,5,7,9 take ♥, ♥♥, ♥, ♥♥ in cycle.
# Here those positions all happen to hold "ring", so the result matches the
# guarded version -- the difference shows only when the positions differ.
#
# Extracted from stzlisttest.ring, block #40.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

pf()
# Executed in almost 0 second(s)
