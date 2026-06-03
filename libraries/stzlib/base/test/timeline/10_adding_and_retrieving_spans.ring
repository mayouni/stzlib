# Narrative
# --------
# Adding and retrieving spans
#
# Extracted from stztimelinetest.ring, block #10.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")

	? CountSpans()
	#--> 3

	? SpanNames()
	#--> ["Q1", "Q2", "Q3"]

	? Span("Q2")
	#--> ["2024-04-01 00:00:00", "2024-06-30 23:59:59"]

	? HasSpan("Q3")
	#--> TRUE
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
