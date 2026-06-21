# Narrative
# --------
# Locating repeated items in a list, by position, by value, and as value/position pairs.
#
# Softanza distinguishes three views of duplication on a stzList. FindDuplicates()
# returns the positions of the *second and later* occurrences of any repeated item
# (here 5, 6, 8, 10 -- the duplicate "a", "ab", "b", and 1:3). ItemsAtPositions()
# then resolves those positions back to their values. Duplicates() is the direct
# shortcut for those repeated values. DuplicatesZ() is the zipped form: it pairs
# each repeated value with the position list at which the duplicate(s) were found,
# e.g. [ "a", [ 5 ] ]. Note the position component is itself a list, since a value
# may recur at several positions.
#
# Extracted from stzlisttest.ring, block #266.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3,"c" ])

? o1.FindDuplicates()
#--> [ 5, 6, 8, 10 ]

? @@( o1.ItemsAtPositions( o1.FindDuplicates() ) )
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]

? @@( o1.Duplicates() ) + NL
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]

? @@( o1.DuplicatesZ() )
#--> [ [ "a", [ 5 ] ], [ "ab", [ 6 ] ], [ "b", [ 8 ] ], [ [ 1, 2, 3 ], [ 10 ] ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19 (64 bits)
# Executed in 0.03 second(s) in Ring 1.17
