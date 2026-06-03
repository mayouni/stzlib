# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #41.

load "../../stzBase.ring"


o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByMany([ 3, 5, 7], "ring", [ "♥", "♥♥", "♥♥♥" ])
# Or you can say: o1.ReplaceItemAtPositions([ 3, 5, 7], "ring", :ByMany = [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

pf()
#--> Executed in 0.02 second(s)
