# Narrative
# --------
# Finding what happens at a specific time
#
# Extracted from stztimelinetest.ring, block #14.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("MEETING", "2024-03-15 10:00:00")
	AddSpan("PROJECT", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("CAMPAIGN", "2024-03-10 00:00:00", "2024-03-20 23:59:59")
}

? @@NL( oTimeLine.WhatsAt("2024-03-15 10:00:00") )
#--> [
#	[ "MEETING", "point" ],
#	[ "PROJECT", "span" ],
#	[ "CAMPAIGN", "span" ]
# ]

? @@( oTimeLine.WhatsAt("2024-02-15 12:00:00") )
#--> [ ]

pf()
# Executed in 0.03 second(s) in Ring 1.24
