# Narrative
# --------
# Find all square matrices
#
# Extracted from stzmatrextest.ring, block #24.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6]],
	[[1, 2, 3], [4, 5, 6], [7, 8, 9]],
	[[1, 2, 3, 4]]
]

? oMx.CountMatchingMatricesIn(aMatrices)
#--> 2

? @@NL( oMx.FindMatchingMatricesIn(aMatrices) )
#--> [ 1, 3 ]

? @@NL( oMx.MatchingMatricesIn(aMatrices) )
#-->
'
[
	[
		[ 1, 2 ],
		[ 3, 4 ]
	],
	[
		[ 1, 2, 3 ],
		[ 4, 5, 6 ],
		[ 7, 8, 9 ]
	]
]
'

pf()
