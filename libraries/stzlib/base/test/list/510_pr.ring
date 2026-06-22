# Narrative
# --------
# Bracket indexing a stzList: o1[n] reads, o1[value] finds.
#
# stzList overloads the [] operator with two polymorphic behaviours keyed
# by the index type. A NUMERIC index reads the item at that position --
# o1[5] returns the 5th item "A" (1-based, and negatives count from the
# end via Item()). A NON-NUMERIC index returns the list of positions where
# that value occurs -- o1["A"] yields [ 5, 8 ]. For a condition-based scan,
# FindWF(func) returns the positions of every item satisfying a Ring
# predicate; here the items in [ "A", "T", "Z" ] sit at [ 4, 5, 7, 8 ].
# This mirrors the stzString o1[n] / o1["x"] idiom on lists.
#
# Extracted from stzlisttest.ring, block #510.

load "../../stzBase.ring"

pr()

# Operators on stzString

o1 = new stzList([ "S","O","F","T","A","N","Z","A" ])

# Getting a char by position

? o1[5] + NL
#--> "A"

# Finding the occurrences of a substring in the string

? o1["A"]
#--> [ 5, 8 ]

# Getting occurrences of chars verifying a given condition

? @@( o1.FindWF( func x { return Q(x).IsOneOfThese(["A", "T", "Z"]) } ) )
#--> [ 4, 5, 7, 8 ]

pf()
# Executed in 0.07 second(s).
