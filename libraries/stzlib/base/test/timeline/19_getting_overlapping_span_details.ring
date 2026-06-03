# Narrative
# --------
# Getting overlapping span details
#
# Extracted from stztimelinetest.ring, block #19.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("PROJECT_B", "2024-03-15 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-08-31 23:59:59")
}

? @@( oTimeLine.OverlappingSpans() )
#--> [ ["PROJECT_A", "PROJECT_B", 4060799] ]
# Duration shows overlap in seconds

pf()
# Executed in 0.02 second(s) in Ring 1.24
