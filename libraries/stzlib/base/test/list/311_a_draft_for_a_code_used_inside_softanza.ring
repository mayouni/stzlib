# Narrative
# --------
# #ring A draft for a code used inside Softanza
#
# Extracted from stzlisttest.ring, block #311.

load "../../stzBase.ring"


StartProfiler()

aList1 = [ 1,  4,  6, 11, 17 ]
aList2 = [ 9, 13, 14, 20, 21 ]

nLen1 = len(aList1)
nLen2 = len(aList2)

aSections = [] 
aSections + [ aList1[1], aList2[nLen2] ]

del(aList2, nLen2)
nLen2 = len(aList2)

for i = 1 to nLen1 - 1
	
	for q = 1 to nLen2
		if aList2[q] < aList1[i+1]
			aSections + [ aList1[i], aList2[q] ]
			del(aList2, q)
			exit
		ok
	next

next

for q = 1 to nLen2
	if aList2[q] > aList1[i]
		aSections + [ aList1[i], aList2[q] ]
		exit
	ok
next

? @@(aSections)
# [ [ 1, 21 ], [ 6, 9 ], [ 11, 13 ], [ 17, 20 ] ]

StopProfiler()
# Executed in almost 0 second(s).
