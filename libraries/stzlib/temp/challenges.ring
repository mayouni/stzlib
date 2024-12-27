load "../max/stzmax.ring"

/*-----------

pron()
*/
# CHALLENGE ADVENTOFCODE
# https://adventofcode.com/2024/day/1

# PROBLEM STATEMENT (SIMPLIFIED)

# The problem is asking us to calculate the total distance between
# two lists of numbers, where each list represents location IDs.
# Specifically, the solution involves:

#	1. Sorting both lists in ascending order.

#	2. Pairing each number in the left list with the corresponding
#	number in the right list based on their sorted order (e.g.,
#	smallest with smallest, second smallest with second smallest,
#	and so on).

#	3. Calculating the absolute difference for each pair.

#	4. Summing up all the absolute differences to get the total distance.

# The goal is to output the total distance between the two lists after
# following this procedure.

# Step 1: Sort both lists

	aList1 = Sort([ 3, 4, 2, 1, 3, 3 ]) #--> [ 1, 2, 3, 3, 3, 4 ]
	aList2 = Sort([ 4, 3, 5, 3, 9, 3 ]) 	#--> [ 3, 3, 3, 4, 5, 9 ]

# Step 2: Pair elements from the two lists

	aPairs = Pairify([ aList1, aList2 ])
	#--> [ [1, 3], [2, 3], [3, 3], [3, 4], [3, 5], [4, 9] ]


# Steps 3 and 4: Calculate absolute differences for each pair and summing them

	? Sum(AbsDiff(aPairs))
	#--> 11

proff()

/*---------

https://adventofcode.com/2024/day/2


The levels are either all increasing or all decreasing.
Any two adjacent levels differ by at least one and at most three.
In the example above, the reports can be found safe or unsafe by checking those rules:

7 6 4 2 1: Safe because the levels are all decreasing by 1 or 2.
1 2 7 8 9: Unsafe because 2 7 is an increase of 5.
9 7 6 2 1: Unsafe because 6 2 is a decrease of 4.
1 3 2 4 5: Unsafe because 1 3 is increasing but 3 2 is decreasing.
8 6 4 4 1: Unsafe because 4 4 is neither an increase or a decrease.
1 3 6 7 9: Safe because the levels are all increasing by 1, 2, or 3.
So, in this example, 2 reports are safe.

Analyze the unusual data from the engineers. How many reports are safe?
