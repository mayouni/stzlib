# Narrative
# --------
# FindElement() - Find all occurrences of an element in the matrix
#
# Extracted from stzmatrixtest.ring, block #26.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 80, 85, 99 ],
	[ 70, 75, 80 ],
	[ 99, 65, 99 ]
])

? @@( o1.FindElement(99) )
#--> [ [ 1, 3 ], [ 3, 1 ], [ 3, 3 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
