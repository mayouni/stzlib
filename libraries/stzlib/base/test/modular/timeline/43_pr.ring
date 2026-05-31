# Narrative
# --------
# pr()
#
# Extracted from stztimelinetest.ring, block #43.

load "../../../stzBase.ring"


oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-32 23:59:59"
)
#--> ERROR: Invalid datetime format (2024-12-32 23:59:59)!

pf()
