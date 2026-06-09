# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #90.
#ERR Error (R14) : Calling Method without definition: firstnitems

load "../../stzBase.ring"

pr()

aLargeList = []
for i = 1 to 1_000
	aLargeList + "R_ING"
next

o1 = new stzList(aLargeList)
o1.StringifyLowercaseAndReplace("_", "♥")

? o1.FirstNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

? o1.LastNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

pf()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.10 second(s) in Ring 1.19 (64 bits)
# Executed in 0.09 second(s) in Ring 1.19 (32 bits)
# Executed in 0.12 second(s) in Ring 1.17
