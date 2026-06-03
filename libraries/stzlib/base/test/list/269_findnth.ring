# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #269.

load "../../stzBase.ring"

pr()

aLarge = 1:1_000_000

aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]

for i = 1 to 8
	aLarge + aList[i]
next

o1 = new stzList(aLarge)
? o1.FindNth(2, "♥")
#--> 1_000_007

pf()
# Executed in  3.42 second(s) in Ring 1.21
# Executed in  5.74 second(s) in Ring 1.19 (64 bits)
# Executed in  6.11 second(s) in Ring 1.19 (32 bits)
# Executed in 13.13 second(s) in Ring 1.18
# Executed in 14.88 second(s) in Ring 1.17
