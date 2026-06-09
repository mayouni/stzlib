# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #96.
#ERR Error (R14) : Calling Method without definition: firstnitems

load "../../stzBase.ring"

pr()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 1_000
	aLargeList + "_--_"
next

o1 = new stzList(aLargeList)
o1.StringifyAndReplace("_", "♥")

? o1.FirstNItems(5)
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9", "♥--♥" ]

? o1.LastNItems(3)
#--> [ "♥--♥" ], "♥--♥" ], "♥--♥" ]

pf()
# Executed in 0.09 second(s)
