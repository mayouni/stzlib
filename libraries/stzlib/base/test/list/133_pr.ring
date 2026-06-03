# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #133.

load "../../stzBase.ring"

pr()

aBigList = 1:30_000
aMore = [ "A", "B", "2", "A", "A", "B", 2, 2, "." ]
nLen = len(aMore)
for i = 1 to nLen
	aBigList + ("" + aMore[i] + i)
next

o1 = new stzList(aBigList)

@@( o1.Withoutduplication() ) # Or ToSet()
#--> [ "A", "B", "2", 2, "." ]

pf()
# Executed in 3.28 second(s) in Ring 1.21
# Executed in 4.29 second(s) in Ring 1.19
