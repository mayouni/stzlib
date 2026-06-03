# Narrative
# --------
# Example 13: Pattern Explanation
#
# Extracted from stztimextest.ring, block #13.

load "../../stzBase.ring"

pr()

Tmx14 = new stzTimex("{@Event(Meeting) -> @Duration(30m..1h) -> @Event(Break)}")

? "Pattern structure:"
? @@NL(Tmx14.Explain())
#--> Shows tokens, constraints, and semantics
'
[
	[
		"Pattern",
		"{@Event(Meeting) -> @Duration(30m..1h) -> @Event(Break)}"
	],
	[ "TokenCount", 3 ],
	[
		"Tokens",
		[
			[
				[ "index", 1 ],
				[ "type", "event" ],
				[ "label", "Meeting" ]
			],
			[
				[ "index", 2 ],
				[ "type", "duration" ],
				[ "label", "" ],
				[
					"constraints",
					[
						[
							[ "type", "range" ],
							[ "start", "30m" ],
							[ "end", "1h" ],
							[ "step", "" ]
						]
					]
				]
			],
			[
				[ "index", 3 ],
				[ "type", "event" ],
				[ "label", "Break" ]
			]
		]
	],
	[ "TargetSet", 1 ],
	[ "LastMatch", 0 ]
]
'
pf()
