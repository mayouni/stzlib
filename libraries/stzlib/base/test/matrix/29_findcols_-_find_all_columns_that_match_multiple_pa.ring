# Narrative
# --------
# FindCols() - Find all columns that match multiple patterns
#
# Extracted from stzmatrixtest.ring, block #29.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 88, 85, 88, 1 ],
	[ 70, 88, 70, 1 ],
	[ 99, 65, 99, 1 ]
	
])

? @@( o1.FindCols([
	[ 1, 1, 1 ],
	[ 88, 70, 99 ]
]) )
#--> [ 1, 3, 4 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
