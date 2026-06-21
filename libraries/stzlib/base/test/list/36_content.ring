# Narrative
# --------
# ReplaceItemAtPositionsByMany: value-guarded replacement, 1-to-1 (no XT
# cycling).
#
# At positions 3, 5, 7 -- only where the item is "ring" -- substitute the
# replacements in order: ♥, ♥♥, ♥♥♥. Without the "XT" suffix the palette is
# NOT recycled (it pairs one replacement per position). The trailing "ring"
# at position 9 isn't listed, so it stays.
#
# Extracted from stzlisttest.ring, block #36.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByMany([ 3, 5, 7], "ring", [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

pf()
# Executed in almost 0 second(s)
