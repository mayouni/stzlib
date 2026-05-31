# Narrative
# --------
# Point outside boundaries (raises error)
#
# Extracted from stztimelinetest.ring, block #39.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddPoint("FUTURE", "2025-01-15 10:00:00")
#--> ERROR: Point 'FUTURE' is outside timeline boundaries 

pf()
