# Narrative
# --------
# Mixed blocked spans and points
#
# Extracted from stztimelinetest.ring, block #51.

load "../../../stzBase.ring"


pr()

oTimeline = new stzTimeLine("2024-06-01", "2024-06-30")
oTimeline.AddBlockedSpan("FREEZE", "2024-06-15", "2024-06-20")
oTimeline.AddBlockedPoint("2024-06-10 10:00:00")

//oTimeline.AddPoint("EVENT1", "2024-06-10 10:00:00")
#--> ERROR: Point 'EVENT1' falls within a blocked span or blocked point 

oTimeline.AddPoint("EVENT2", "2024-06-17 14:00:00")
#--> oint 'EVENT2' falls within a blocked span or blocked point 

oTimeline.AddPoint("EVENT3", "2024-06-05 09:00:00")  # OK

pf()
