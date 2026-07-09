# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #38.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
o1.ReplaceAnyItemsAtPositions([ 1, 3, 4, 5 ], :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "♥♥♥", "softanza" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.07 second(s) before
