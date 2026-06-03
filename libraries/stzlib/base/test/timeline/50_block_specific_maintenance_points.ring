# Narrative
# --------
# Block specific maintenance points
#
# Extracted from stztimelinetest.ring, block #50.

load "../../stzBase.ring"


pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-01-31")
oTimeline.AddBlockedPoint("2024-01-15 12:00:00")
oTimeline.AddBlockedPoint("2024-01-20 09:00:00")

oTimeline.AddPoint("MEETING", "2024-01-15 12:00:00")
#--> ERROR: Point 'MEETING' falls within a blocked span or blocked point 

oTimeline.AddPoint("LAUNCH", "2024-01-15 14:00:00")   # OK

pf()
