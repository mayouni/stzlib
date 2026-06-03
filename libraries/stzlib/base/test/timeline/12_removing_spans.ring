# Narrative
# --------
# Removing spans
#
# Extracted from stztimelinetest.ring, block #12.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpans([
		[ "PHASE1", "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
		[ "PHASE2", "2024-04-01 00:00:00", "2024-06-30 23:59:59" ],
		[ "PHASE3", "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	])

	? CountSpans()
	#--> 3

	RemoveSpan("PHASE2")

	? CountSpans()
	#--> 2

	? SpanNames()
	#--> [ "PHASE1", "PHASE3" ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.24
