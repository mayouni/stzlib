# Narrative
# --------
# FindRows() - Find all rows that match multiple patterns
#
# Extracted from stzmatrixtest.ring, block #31.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 7, 21, 88 ],
	[ 0,  0,  0 ],
	[ 1, 11, 11 ],
	[ 7, 21, 88 ],
	[ 0,  0,  0 ]
])


? @@( o1.FindRows([
	[ 7, 21, 88 ],
	[ 0,  0,  0 ]
]) )
#--> [ 1, 2, 4, 5 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
