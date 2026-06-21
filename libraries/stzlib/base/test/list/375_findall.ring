# Narrative
# --------
# FindAll and FindFirst locate list-valued items inside a stzList by
# deep structural equality, not just scalars.
#
# Softanza treats a nested list like [1, 2] as a first-class item: you
# can ask where it occurs and FindAll returns every matching position
# while FindFirst returns the earliest one. The match is recursive, so
# arbitrarily deep shapes such as [ 1, ["v", ["u"] ], 2 ] are compared
# element-by-element at every level. Here both lists appear at positions
# 3 and 6, so FindAll gives [3, 6] and FindFirst gives 3 in each case.
#
# Extracted from stzlisttest.ring, block #375.

load "../../stzBase.ring"

pr()

# In Softanza, you can find lists inside lists:

o1 = new stzList([ "A", "B", [1, 2], "C", "D", [1, 2], "E" ])

? o1.FindAll([1, 2])
#--> [3, 6]

? o1.FindFirst([1, 2]) + NL
#--> 3

# And you can go deep and find even more complicated lists:

o1 = new stzList([
		"A", "B",
		[ 1, ["v", ["u"] ], 2 ],
		"C", "D",
		[ 1, ["v", ["u"] ], 2 ],
		"E"
])

? o1.FindAll( [ 1, ["v", ["u"] ], 2 ] )
#--> [ 3, 6]

? o1.FindFirst([ 1, ["v", ["u"] ], 2 ])
#--> 3

pf()
# Executed in 0.02 second(s).
