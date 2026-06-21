# Narrative
# --------
# Min/max interrogation of a stzList, including ranked Nth-smallest lookup.
#
# Smallest() and Largest() return the extreme values (3 and 10) of
# [ 7, 3, 3, 10, 8, 8 ]. The Find* variants return the POSITIONS of those
# values: FindSmallest() -> [ 2, 3 ] (the two 3's), FindLargest() -> [ 4 ].
# NumberOfOccurrencesOfSmallestItem() and its short alias NumberOfSmallest()
# both count how many times the minimum appears (2). NthSmallest(n) ranks the
# DISTINCT values ascending and returns the n-th: distinct of this list is
# [ 3, 7, 8, 10 ], so the 3rd smallest is 8 -- and FindNthSmallest(3) returns
# the positions of that value, [ 5, 6 ]. (Ranking is over distinct values, not
# the duplicated raw sequence.)
#
# Extracted from stzlisttest.ring, block #332.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 7, 3, 3, 10, 8, 8 ])

? o1.Smallest()
#--> 3

? o1.Largest()
#--> 10

? @@( o1.FindSmallest() )
#--> [ 2, 3 ]

? o1.NumberOfOccurrencesOfSmallestItem()
#--> 2

# or more simply

? o1.NumberOfSmallest()
#--> 2

? @@( o1.FindLargest() )
#--> [ 4 ]

? o1.NthSmallest(3)
#--> 8

? @@( o1.FindNthSmallest(3) )
#--> [ 5, 6 ]

pf()
# Executed in 0.01 second(s)
