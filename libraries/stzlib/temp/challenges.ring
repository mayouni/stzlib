load "../max/stzmax.ring"

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

profon()

aList1 = [ 3, 4, 2, 1, 3, 3 ]
aList2 = [ 4, 3, 5, 3, 9, 3]

# First step : Sorting bother lists

aSorted1 = @Sort(aList1)
aSorted2 = @sort(aList2)

	? @@(aSorted1) + NL
	#--> 
	? @@(aSorted2) + NL

# Second step:

aPairs = Pairify([ aSorted1, aSorted2 ])

	? @@(aPairs)
	#--> [ [ 1, 3 ], [ 2, 3 ], [ 3, 3 ], [ 3, 4 ], [ 3, 5 ], [ 4, 9 ] ]

# Third step: Absolute difference for each pair

? @@( AbsDiff(aPairs) ) # Absolute difference 1 to 1
#--> [ 2, 1, 0, 1, 2, 5 ]

# Fourth step : Getting their sum

? Sum( AbsDiff(aPairs) )


proff()
