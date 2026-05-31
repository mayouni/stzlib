# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #47.

load "../../../stzBase.ring"


o1 = new stzLists([ # or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.AdjustXT(:To = 3, :Using = AHeart())

o1.Show()
#--> [
#	[ "A", "B", "♥" ],
#	[ "C", "D", "E" ],
#	[ "I", "♥", "♥" ]
# 

pf()
# Executed in 0.03 second(s) in Ring 1.21
