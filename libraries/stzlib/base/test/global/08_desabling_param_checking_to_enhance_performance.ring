# Narrative
# --------
# #perf Desabling param checking to enhance performance
#
# Extracted from stzGlobalTest.ring, block #8.

load "../../stzBase.ring"

#TODO // Generalize this feature to all Softanza functions

# Softanza functions do a lot of work in checking params correctness.
# You can see it by yourself by reading any function code.
# But this comes with a performance cost, especially when you use
# theses functions in loops dealing with large lists.

# For example, the function EuclideanDistance() cheks by default for
# the params to be both lists of numbers of same size:

//? EuclideanDistance(1:3, 1:5)
#!--> Incorrect lists sizes! anNumbers1 and anNumbers2 must both have the same size.

# It does not allow you to use incorrect types:
//? EuclideanDistance('A':'C', 1:3)
#!--> Incorrect param types! anNumbers1 and anNumbers2 must be both lists of numbers.

# And so on.

# Now, if we use the function for a large number of items:

aList1 = 1 : 1_500_000
aList2 = 4 : 1_500_003

pr()

? EuclideanDistance(aList1, aList2)
#--> 3674.23

# A lot.

pf()
# Executed in 19.32 second(s) in Ring 1.22
# Executed take 25.54 seconds in Ring 1.19
