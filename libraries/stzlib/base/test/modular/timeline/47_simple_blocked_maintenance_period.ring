# Narrative
# --------
# Simple blocked maintenance period
#
# Extracted from stztimelinetest.ring, block #47.

load "../../../stzBase.ring"


pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeline.AddBlockedSpan("MAINTENANCE", "2024-06-15 09:00:00", "2024-06-15 17:00:00")
oTimeline.AddPoint("EVENT1", "2024-06-15 08:00:00")  # OK
oTimeline.AddPoint("EVENT2", "2024-06-15 12:00:00")  # Error: blocked
#--> Point 'EVENT2' falls within a blocked span 

pf()
