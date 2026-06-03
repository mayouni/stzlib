# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #923.
#ERR Error (R14) : Calling Method without definition: replaceitemsatpositionsbymany

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemsAtPositionsByMany([ 3, 5, 7], [ "♥", "♥♥", "♥♥♥" ])

? @@( o1.Content() )
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

pf()
# Executed in almost 0 second(s).
