# Narrative
# --------
# #ring A draft for a code using inside Softanza
#
# Extracted from stzlisttest.ring, block #314.

load "../../stzBase.ring"


StartProfiler()

aList1  = [ 1, 4, 6,   11,        18        ,    24  ]
aList2  = [          9,    14, 15,    21, 22, 23     ]

aList = Q(aList1).MergeWithQ(aList2).Sorted()

aSections = []
bContinue = TRUE

while TRUE

	for i = 2 to len(aList)
	
		if find(aList1, aList[i-1]) > 0 and
		   find(aList2, aList[i]) > 0
	
			aSections + [ aList[i-1], aList[i] ]
			if len(aSections) = 5
				exit 2
			ok

		ok
	next
	
	aList = Q(aList).ManyRemoved(Q(aSections).Merged())

end

? @@(aSections)
# [ [ 6, 9 ], [ 11, 14 ], [ 18, 21 ], [ 4, 15 ], [ 1, 22 ] ]

StopProfiler()
# Executed in 0.01 second(s).
