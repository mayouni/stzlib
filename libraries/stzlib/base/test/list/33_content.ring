# Narrative
# --------
# Two similar replacers contrasted: position-driven vs value-guarded.
#
# ReplaceAnyItemAtPositionsByManyXT([3,5,7,9], [...]) replaces WHATEVER sits
# at those positions, cycling the replacement palette -> positions 3,5,7,9
# become ♥,♥♥,♥,♥♥. ReplaceItemAtPositionsByManyXT([1,3,5,7,9], "ring", [...])
# adds a VALUE guard: it only replaces those positions if they hold "ring"
# (all do here), again cycling -> ♥,♥♥,♥,♥♥,♥. The guard is the difference.
#
# Extracted from stzlisttest.ring, block #33.

load "../../stzBase.ring"

pr()

# First snippet -- position-driven (no value guard)

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

# Second snippet -- value-guarded (only where the item is "ring")

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByManyXT([ 1, 3, 5, 7, 9], "ring", [ "♥", "♥♥" ])

? o1.Content()
#--> [ "♥", "php", "♥♥", "ruby", "♥", "python", "♥♥", "csharp", "♥" ]

pf()
# Executed in almost 0 second(s)
