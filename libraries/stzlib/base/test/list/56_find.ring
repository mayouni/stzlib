# Narrative
# --------
# Find -> ReplaceAnyItemsAtPositions: the canonical "locate then act on the
# positions" idiom.
#
# Find("♥") returns every position holding "♥" ([2,3,7,8]); feeding that list
# straight into ReplaceAnyItemsAtPositions(..., :By="★") overwrites exactly
# those slots. "Any" means the value at each found position is replaced
# unconditionally -- the guard is unnecessary because Find already filtered.
#
# Extracted from stzlisttest.ring, block #56.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "♥", "♥", "4", "5", "6", "♥", "♥", "9" ])

anPos = o1.Find("♥")
#--> [ 2, 3, 7, 8 ]

o1.ReplaceAnyItemsAtPositions( o1.Find("♥"), :By = "★" )
? @@( o1.Content() )
#--> [ "1", "★", "★", "4", "5", "6", "★", "★", "9" ]

pf()
# Executed in 0.06 second(s)
