# Narrative
# --------
# Creating timelines with date-only inputs
#
# Extracted from stzlistoftimelinestest.ring, block #2.

load "../../../stzBase.ring"


pr()

o1 = new stzTimeLines([
	:Lanes = [ "Dev", "QA" ],
	:From  = "2024-10-10",
	:To    = "2024-10-22 16:40:00"
])

? @@NL( o1.Content() )  # Time added automatically to "2024-10-10"
#--> [
#	[ "start", "2024-10-10 00:00:00" ],
#	[ "end", "2024-10-22 16:40:00" ],
#	[
#		"lanes",
#		[ "DEV", "QA" ]
#	],
#	[
#		"timelines",
#		[
#			[ "lane", "DEV" ],
#			[ "content", [ ... ] ]  # Empty timeline content
#		],
#		[
#			[ "lane", "QA" ],
#			[ "content", [ ... ] ]
#		]
#	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.24
