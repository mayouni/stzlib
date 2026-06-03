# Narrative
# --------
# Explain pattern
#
# Extracted from stzmatrextest.ring, block #43.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(2x2) & property(symmetric)}")

aMatrix = [[1, 2], [2, 3]]
oMx.Match(aMatrix)

? @@NL( oMx.Explain() )
#-->
'
[
	[ "Pattern", "{size(2x2) & property(symmetric)}" ],
	[ "TokenCount", 1 ],
	[
		"Tokens",
		[
			[
				[ "type", "conjunction" ],
				[
					"conditions",
					[
						[
							[ "type", "size" ],
							[ "value", "2x2" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						],
						[
							[ "type", "property" ],
							[ "value", "symmetric" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						]
					]
				],
				[ "negated", 0 ]
			]
		]
	],
	[
		"Target",
		[
			[ 1, 2 ],
			[ 2, 3 ]
		]
	],
	[
		"MatchedParts",
		[
			[
				"Size",
				[ 2, 2 ]
			],
			[
				"Matrix",
				[
					[ 1, 2 ],
					[ 2, 3 ]
				]
			],
			[
				"Properties",
				[ "Square", "Symmetric" ]
			]
		]
	]
]
'

pf()

#==============#
#  EDGE CASES  #
#==============#
