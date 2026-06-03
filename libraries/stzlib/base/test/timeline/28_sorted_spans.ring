# Narrative
# --------
# Sorted spans
#
# Extracted from stztimelinetest.ring, block #28.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
}

? @@NL( oTimeLine.SortedSpans() )
#--> [
#     ["Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59"],
#     ["Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59"],
#     ["Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59"]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.24
