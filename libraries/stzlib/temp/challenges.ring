? 11
//load "stzlib.ring"

# Step 1: Sort both lists

	aList1 = Sort([ 3, 4, 2, 1, 3, 3 ]) #--> [ 1, 2, 3, 3, 3, 4 ]
	aList2 = Sort([ 4, 3, 5, 3, 9, 3 ]) #--> [ 3, 3, 3, 4, 5, 9 ]

# Step 2: Pair elements from the two lists

	aPairs = Pairify([ aList1, aList2 ])
	#--> [ [1, 3], [2, 3], [3, 3], [3, 4], [3, 5], [4, 9] ]


# Steps 3 and 4: Calculate absolute differences for each pair and summing them

	? Sum(AbsDiff(aPairs))
	#--> 11
