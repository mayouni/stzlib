# Narrative
# --------
#
# Extracted from stzlisttest.ring, block #630.

load "../../stzBase.ring"


pr()

o1 = new stzList([ "green", [ "A", "B" ], "rediness", "blues" ])

? @@NL( o1.DiffXTT([ "yellow", "red", [ "A" ], "blue", "gray" ]) )
#-->
'
[
	[
		"added",
		[ "yellow", "gray" ]
	],
	[
		"removed",
		[ "green" ]
	],
	[
		"modified",
		[
			[
				[ "A", "B" ],
				[ "A" ]
			],
			[ "rediness", "red" ],
			[ "blues", "blue" ]
		]
	]
]
'

pf()
# Executed in 0.04 second(s) in Ring 1.24
