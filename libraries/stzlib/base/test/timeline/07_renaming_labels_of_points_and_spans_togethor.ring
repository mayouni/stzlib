# Narrative
# --------
# Renaming labels (of points and spans togethor)
#
# Extracted from stztimelinetest.ring, block #7.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeLine {

	AddPoints([ 
		[ "HR-EVAL", "2024-03-15 10:00:00" ],
		[ "KICKOFF", "2024-05-16 14:30:00" ],
		[ "HR-EVAL", "2024-08-17 09:00:00" ]
	])

	AddSpans([
		[ "PREP", "2024-03-15", "2024-05-15" ],
		[ "HR-EVAL", "2024-11-01", "2024-11-25" ]
	])

	? @@NL( Content() ) + NL

	# replacing the 2 moments and 1 spance having "HR-EVAL" as label:

	RenameLabel("HR-EVAL", "PERF-REVIEW")

	? @@NL( Content() )

}
#--> Before renaming:
'
[
	[ "start", "2024-01-01 00:00:00" ],
	[ "end", "2024-12-31 00:00:00" ],
	[
		"points",
		[
			[ "HR-EVAL", "2024-03-15 10:00:00" ],
			[ "KICKOFF", "2024-05-16 14:30:00" ],
			[ "HR-EVAL", "2024-08-17 09:00:00" ]
		]
	],
	[
		"spans",
		[
			[
				"PREP",
				"2024-03-15 00:00:00",
				"2024-05-15 00:00:00"
			],
			[
				"HR-EVAL",
				"2024-11-01 00:00:00",
				"2024-11-25 00:00:00"
			]
		]
	]
]
' 
#--> After renaming:
'
[
	[ "start", "2024-01-01 00:00:00" ],
	[ "end", "2024-12-31 00:00:00" ],
	[
		"points",
		[
			[ "PERF-REVIEW", "2024-03-15 10:00:00" ],
			[ "KICKOFF", "2024-05-16 14:30:00" ],
			[ "PERF-REVIEW", "2024-08-17 09:00:00" ]
		]
	],
	[
		"spans",
		[
			[
				"PREP",
				"2024-03-15 00:00:00",
				"2024-05-15 00:00:00"
			],
			[
				"PERF-REVIEW",
				"2024-11-01 00:00:00",
				"2024-11-25 00:00:00"
			]
		]
	]
]
'

pf()
# Executed in 0.02 second(s) in Ring 1.24
