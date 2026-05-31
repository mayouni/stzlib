# Narrative
# --------
# Span boundaries and duration
#
# Extracted from stztimelinetest.ring, block #11.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpan("PROJECT", "2024-03-01 00:00:00", "2024-08-31 23:59:59")

	? SpanStart("PROJECT")
	#--> 2024-03-01 00:00:00

	? SpanEnd("PROJECT")
	#--> 2024-08-31 23:59:59

	? SpanDuration("PROJECT")
	#--> 15897599 (seconds)

	? SpanDurationQ("PROJECT").ToHuman()
	#--> 6 months
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
