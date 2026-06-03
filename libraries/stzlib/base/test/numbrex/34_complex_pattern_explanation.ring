# Narrative
# --------
# COMPLEX PATTERN EXPLANATION
#
# Extracted from stznumbrextest.ring, block #34.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Property(Even) & @Digit3 & @Relation(Mod:5=0)}")
? @@NL( Nx.Explain() )
#-->
'
[
	[
		"Pattern",
		"{@Property(Even) & @Digit3 & @Relation(Mod:5=0)}"
	],
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
							[ "type", "property" ],
							[ "value", "Even" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						],
						[
							[ "type", "digit" ],
							[ "value", "" ],
							[ "constraints", [  ] ],
							[ "min", 3 ],
							[ "max", 3 ],
							[ "negated", 0 ]
						],
						[
							[ "type", "relation" ],
							[ "value", "Mod:5=0" ],
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
	]
]
'

pf()
