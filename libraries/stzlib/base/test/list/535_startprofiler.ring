# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #535.

load "../../stzBase.ring"


o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])
o1.ReplaceItemsAtPositions([2, 5], :With = "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

StopProfiler()
#--> Executed in almost 0 second(s).
