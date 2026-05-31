# Narrative
# --------
# PATTERN EXPLANATION
#
# Extracted from stznumbrextest.ring, block #33.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Property(Prime)}")
? @@NL( Nx.Explain() )
#-->
'
[
	[ "Pattern", "{@Property(Prime)}" ],
	[ "TokenCount", 1 ],
	[
		"Tokens",
		[
			[
				[ "type", "property" ],
				[ "value", "Prime" ],
				[ "constraints", [  ] ],
				[ "min", 1 ],
				[ "max", 1 ],
				[ "negated", 0 ]
			]
		]
	]
]
'

pf()
