# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #273.

load "../../../stzBase.ring"


aLarge = 1:1_000_000

aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]

for i = 1 to 8
	aLarge + aList[i]
next

o1 = new stzList(aLarge)
? o1.FindLast("♥")
#--> 1000007

pf()
# Executed in  5.00 second(s) in Ring 1.21
# Executed in  6.51 second(s) in Ring 1.19
# Executed in 14.32 second(s) in Ring 1.17
