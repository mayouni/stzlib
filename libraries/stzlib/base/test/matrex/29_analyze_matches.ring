# Narrative
# --------
# Analyze matches
#
# Extracted from stzmatrextest.ring, block #29.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(2x2)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[5, 6], [7, 8]],
	[[1, 2, 3], [4, 5, 6]],
	[[9, 10], [11, 12]]
]

? @@NL( oMx.AnalyzeMatches(aMatrices) )
#-->
'
[
	[ "pattern", "{size(2x2)}" ],
	[ "totalmatrices", 4 ],
	[ "matchingcount", 3 ],
	[ "nonmatchingcount", 1 ],
	[ "matchrate", 0.75 ],
	[
		"matching",
		[
			[
				[ 1, 2 ],
				[ 3, 4 ]
			],
			[
				[ 5, 6 ],
				[ 7, 8 ]
			],
			[
				[ 9, 10 ],
				[ 11, 12 ]
			]
		]
	],
	[
		"nonmatching",
		[
			[
				[ 1, 2, 3 ],
				[ 4, 5, 6 ]
			]
		]
	]
]
'

pf()
