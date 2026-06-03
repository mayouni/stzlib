# Narrative
# --------
# Span outside boundaries (raises error)
#
# Extracted from stztimelinetest.ring, block #40.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddSpan("OVERFLOW", "2024-11-01 00:00:00", "2025-02-28 23:59:59")
#--> ERROR: Span 'OVERFLOW' is outside timeline boundaries 

pf()
