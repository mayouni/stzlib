# Narrative
# --------
# pr()
#
# Extracted from stztimelinetest.ring, block #3.

load "../../stzBase.ring"

pr()

o1 = new stzTimeLine("2024-01-01", "2024-03-20")
o1.AddPoint("EVENT", "2024-03-15") # time added automatically "00:00:00"
? o1.Point("EVENT")
#--> 2024-03-15 00:00:00

o1.AddSpan("WEEK", "2024-03-01", "2024-03-07")  # Both dates normalized
? @@(o1.Span("WEEK"))
#--> [ "2024-03-01 00:00:00", "2024-03-07 00:00:00" ]

o1.SetStart("2024-01-01") # Works without time
? o1.Start()
#--> 2024-01-01 00:00:00

? @@NL( o1.Content() ) + NL
#--> [
#	[ "start", "2024-01-01 00:00:00" ],
#	[ "end", "2024-03-20 00:00:00" ],
#	[
#		"points",
#		[
#			[ "EVENT", "2024-03-15 00:00:00" ]
#		]
#	],
#	[
#		"spans",
#		[
#			[
#				"WEEK",
#				"2024-03-01 00:00:00",
#				"2024-03-07 00:00:00"
#			]
#		]
#	]
# ]

? @@( o1.Points() ) + NL
#--> [ [ "EVENT", "2024-03-15 00:00:00" ] ]

? @@( o1.Spans() )
#--> [ [ "WEEK", "2024-03-01 00:00:00", "2024-03-07 00:00:00" ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.24

#------------------------#
#  TimePoint Management  #
#------------------------#
