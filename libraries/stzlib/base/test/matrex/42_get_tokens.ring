# Narrative
# --------
# Get tokens
#
# Extracted from stzmatrextest.ring, block #42.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square) | shape(rectangular)}")

? @@NL( oMx.Tokens() )
#-->
'
[
	[
		[ "type", "alternation" ],
		[
			"alternatives",
			[
				[
					[ "type", "shape" ],
					[ "value", "square" ],
					[ "constraints", [  ] ],
					[ "min", 1 ],
					[ "max", 1 ],
					[ "negated", 0 ]
				],
				[
					[ "type", "shape" ],
					[ "value", "rectangular" ],
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
'

pf()
