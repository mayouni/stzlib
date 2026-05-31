# Narrative
# --------
# FindCol() - Find columns that match a pattern
#
# Extracted from stzmatrixtest.ring, block #28.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 88, 85, 88 ],
	[ 70, 88, 70 ],
	[ 99, 65, 99 ]
])

? @@( o1.FindCol([ 88, 70, 99 ]) )
#--> [ 1, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
