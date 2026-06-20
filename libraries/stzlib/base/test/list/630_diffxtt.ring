# Narrative
# --------
# DiffXTT: a structural diff between two lists -- added, removed, and
# MODIFIED items.
#
# Beyond a plain set difference, DiffXTT also pairs up items that merely
# CHANGED (are similar but not identical) into a "modified" bucket, and
# removes those from added/removed so each item is reported once:
#   - added    : in the other list, with no counterpart here
#   - removed  : here, with no counterpart in the other list
#   - modified : [ old, new ] pairs where one contains/overlaps the other
# So ["A","B"]~["A"] (sublist overlap), "rediness"~"red" and "blues"~"blue"
# (substring) are modifications, leaving "green" removed and
# "yellow"/"gray" added.
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
# Executed in 0.04 second(s)
