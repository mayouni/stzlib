# Narrative
# --------
# TODO: Maybe this should move to stzText
#
# Extracted from stzStringTest.ring, block #798.

load "../../../stzBase.ring"


pr()

o1 = new stzString("ring language isسلام  a nice language")

? o1.Orientation()
#--> :LeftToRight

? o1.ContainsHybridOrientation()
#--> TRUE

#---

o1 = new stzString("سلام عليكم ياأهل مصر hello الكرام")

? o1.Orientation()
#--> :RightToLeft

? o1.ContainsHybridOrientation()
#--> TRUE

pf()
# Executed in 0.09 second(s).
