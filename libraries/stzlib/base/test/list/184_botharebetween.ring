# Narrative
# --------
# Checks whether BOTH numbers in a pair lie inside an inclusive range.
#
# A QRT-wrapped pair, typed as :stzPairOfNumbers, exposes
# BothAreBetween(nLow, nHigh): it returns TRUE only when each member
# of the pair satisfies nLow <= member <= nHigh. Here the upper bound
# is computed dynamically from a host list via o1.NumberOfItems() (= 5),
# a common Softanza idiom for bounds-checking a pair of positions
# against the size of a collection. [2,4] fits within 1..5 -> TRUE;
# [0,4] fails because 0 is below the low bound -> FALSE.
#
# Extracted from stzlisttest.ring, block #184.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 14, 10, 14, 14, 20 ])

? QRT([2, 4], :stzPairOfNumbers).BothAreBetween(1, o1.NumberOfItems())
#--> TRUE

? QRT([0, 4], :stzPairOfNumbers).BothAreBetween(1, o1.NumberOfItems())
#--> FALSE

pf()
# Executed in 0.05 second(s)
