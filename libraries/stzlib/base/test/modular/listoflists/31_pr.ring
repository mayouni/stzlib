# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #31.

load "../../../stzBase.ring"


o1 = new stzList([
	[1, 2],
	[3, [4, 5:7 ] ],
	8,
	[ [ 9, [10] ] ]
])

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

pf()
# Executed in 0.03 second(s)
