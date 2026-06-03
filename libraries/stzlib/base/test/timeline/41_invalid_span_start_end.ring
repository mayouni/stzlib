# Narrative
# --------
# Invalid span (start >= end)
#
# Extracted from stztimelinetest.ring, block #41.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddSpan("INVALID", "2024-03-15 10:00:00", "2024-03-15 10:00:00")
#--> ERROR: Span 'INVALID' has invalid dates. Start time (2024-03-15 10:00:00)
# must be before end time (2024-03-15 10:00:00)

pf()
