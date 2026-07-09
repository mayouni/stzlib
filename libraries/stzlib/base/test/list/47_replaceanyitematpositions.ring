# Narrative
# --------
# ReplaceAnyItemAtPositions: replace whatever sits at the listed positions
# with a single value.
#
# Positions 1 and 5 (both "ring", but the value is irrelevant under "Any")
# are overwritten by "♥♥♥". The named :By argument reads as prose --
# "replace any item at positions [1,5] by ♥♥♥". The middle "ring" at
# position 3 is not listed, so it survives.
#
# Extracted from stzlisttest.ring, block #47.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "ruby", "ring", "php", "ring" ])
o1.ReplaceAnyItemAtPositions([ 1, 5 ], :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "ring", "php", "♥♥♥" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.06 second(s) before
