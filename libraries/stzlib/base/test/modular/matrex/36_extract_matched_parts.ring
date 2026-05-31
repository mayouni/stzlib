# Narrative
# --------
# Extract matched parts
#
# Extracted from stzmatrextest.ring, block #36.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(3x3) & property(symmetric)}")

aMatrix = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

oMx.Match(aMatrix)

aParts = oMx.MatchedParts()
? @@(aParts["Size"])
#--> [3, 3]

? aParts["Properties"]
#--> ["Square", "Symmetric"]

? @@NL(aParts)
#-->
'
[
	[
		"Size",
		[ 3, 3 ]
	],
	[
		"Matrix",
		[
			[ 1, 2, 3 ],
			[ 2, 4, 5 ],
			[ 3, 5, 6 ]
		]
	],
	[
		"Properties",
		[ "Square", "Symmetric" ]
	]
]
'

pf()
