# Narrative
# --------
# FindElements() - Find all occurrences of multiple elements
#
# Extracted from stzmatrixtest.ring, block #27.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 88, 85, 99 ],
	[ 70, 88, 80 ],
	[ 99, 65, 99 ]
])

? @@( o1.FindElements([ 88, 99 ]) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 1, 3 ], [ 3, 1 ], [ 3, 3 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
