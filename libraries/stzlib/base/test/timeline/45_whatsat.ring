# Narrative
# --------
# pr()
#
# Extracted from stztimelinetest.ring, block #45.

load "../../stzBase.ring"

pr()

o1 = new stzTimeLine(
	:Start = "2024-03-01 00:00:00",
	:End   = "2024-03-30 00:00:00"
)

o1 {

	AddMoment("One", "2024-03-15 10:00:00")
	AddMoment("Two", "2024-03-15 10:00:00")
	AddMoment("Three", "2024-03-15 10:00:00")

	AddSpan("Phase1", "2024-03-15 00:00:00", "2024-03-18 10:00:00")

	? @@NL(WhatsAt("2024-03-15 10:00:00")) + NL
	#--> [
	# [
	# 	[ "One", "point" ],
	# 	[ "Two", "point" ],
	# 	[ "Three", "point" ],
	# 	[ "Phase1", "span" ]
	# ]

	? @@NL(WhatsAt("2024-03-15")) + NL         # Date only: all events on that date
	#--> [
	# 	[ "One", "point" ],
	# 	[ "Two", "point" ],
	# 	[ "Three", "point" ],
	# 	[ "Phase1", "span" ]
	# ]

	? @@NL(WhatsAt("10:00:00") )            # Time only: all events at that time
	#--> [
	# 	[ "One", "point" ],
	# 	[ "Two", "point" ],
	# 	[ "Three", "point" ],
	# 	[ "Phase1", "span" ]
	# ]

	? @@NL(PointNamesXT()) + NL           # [["EVENT1", 3], ["EVENT2", 1]]
	#--> [
	# 	[ "One", 1 ],
	# 	[ "Two", 1 ],
	# 	[ "Three", 1 ]
	# ]

	? @@(WhatsBetween("2024-03-12", "2024-03-18"))
	#--> [ "One", "Two", "Three" ]

}

pf()
# Executed in 0.05 second(s) in Ring 1.24
