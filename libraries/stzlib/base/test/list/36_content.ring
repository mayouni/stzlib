# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #36.
#ERR Error (R14) : Calling Method without definition: replaceitematpositionsbymany

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByMany([ 3, 5, 7], "ring", [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

pf()
# Executed in 0.04 second(s)
