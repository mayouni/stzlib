# Narrative
# --------
# FindRow() - Find rows that match a pattern
#
# Extracted from stzmatrixtest.ring, block #30.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 7, 21, 88 ],
	[ 1, 11, 11 ],
	[ 7, 21, 88 ]
])

? @@( o1.FindRow([ 7, 21, 88 ]) )
#--> [ 1, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
