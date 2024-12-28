load "../max/stzmax.ring"

/*-----------

pron()

# CHALLENGE ADVENTOFCODE DAY 1
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

/*--------- #TODO

# # CHALLENGE ADVENTOFCODE DAY 2
# https://adventofcode.com/2024/day/2

# Write an algorithm that check if a lists of numbers is safe or unsafe.

# A list of numbers is considered safe when:
# 	1) ~> The numbers are either all increasing or all decreasing.
# 	2) ~> Any two adjacent numbers differ by at least one and at most three.

# For example :

# c: Safe because the levels are all decreasing by 1 or 2.
# [ 1, 2, 7, 8, 9 ] : Unsafe because 2:7 is an increase of 5.
# [ 9, 7, 6, 2, 1 ] : Unsafe because 6:2 is a decrease of 4.
# [ 1, 3, 2, 4, 5 ] : Unsafe because 1:3 is increasing but 3:2 is decreasing.
# [ 8, 6, 4, 4, 1 ] : Unsafe because 4:4 is neither an increase or a decrease.
# [ 1, 3, 6, 7, 9 ] : Safe because the levels are all increasing by 1, 2, or 3.

? QQ([ 1, 2, 7, 8, 9 ]).CheckThat('{
	Q(@List).IsSorted() and
	Q(@NextNumber - @CurrentNumber).IsBetween(1, :And = 3)
}')
#--> TRUE

# QQ() elevates the list to a stzListOfNumbers object (if it was one Q() it
# would elevate it to a stzList object, but we want to be soecific here, since
# the next code will contain a condion in number.

# Then we use the ChecjThat() function that evaluates a condition agains the list.
# the condition is self-expressive and translates perfectly to the solution instrcution
# defined in the challenge statement:

# 1. The list must be sorted (in assending or in descending)
# 2. the difference betwe a number and the next to it must be between 1 and 3

#-------------------


profon()

@substring = "muldkfhdkfjhtio"

 bOk =	Q(@substring).FirstNChars(3) = "mul" and
	Q(@substring).NthCharQ(4).IsEither( "(", :Or = "]" ) //and
	Q(@substring).LastCharQ().IsEither( ")", :Or = "]")

proff()

/*-------------------

profon()

o1 = new stzString("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))")

o1.Replace([ "[", "]"], :By = [ "(", ")" ])

? o1.BoundedByIB([ "mul(", ")" ])
#--> [
#	"mul(2,4)",
#	"mul(3,7)",
#	"mul(5,5)",
#	"mul(32,64)",
#	"mul(11,8)",
#	"mul(8,5)"
# ]

//? Q(aList).YieldXT('{ eval(@item) }') #TODO
#--> 12123

proff()
# Executed in 0.02 second(s) in Ring 1.22


