# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #47.
#ERR Error (R14) : Calling Method without definition: replaceanyitematpositions

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "ruby", "ring", "php", "ring" ])
o1.ReplaceAnyItemAtPositions([ 1, 5 ], :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "ring", "php", "♥♥♥" ]

pf()
# Executed in 0.06 second(s)
