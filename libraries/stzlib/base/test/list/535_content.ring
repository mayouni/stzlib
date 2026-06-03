# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #535.
#ERR Error (R14) : Calling Method without definition: replaceitemsatpositions

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])
o1.ReplaceItemsAtPositions([2, 5], :With = "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

StopProfiler()
#--> Executed in almost 0 second(s).

pf()
