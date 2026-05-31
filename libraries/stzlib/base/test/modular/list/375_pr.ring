# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #375.

load "../../../stzBase.ring"


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
