# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #270.

load "../../stzBase.ring"


aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]
aLarge = aList

for i = 1 to 1_000_000
	aLarge + i
next

o1 = new stzList(aList)
? o1.FindNth(2, "♥")
#--> 7

pf()
# Executed in 0.15 second(s) in Ring 1.21 (64 bits)
# Executed in 0.17 second(s) in Ring 1.19 (64 bits)
# Executed in 0.20 second(s) in Ring 1.19 (32 bits)
# Executed in 0.26 second(s) in Ring 1.18
# Executed in 0.24 second(s) in Ring 1.17
