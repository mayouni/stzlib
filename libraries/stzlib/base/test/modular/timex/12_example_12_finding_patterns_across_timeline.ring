# Narrative
# --------
# Example 12: Finding Patterns Across Timeline
#
# Extracted from stztimextest.ring, block #12.

load "../../../stzBase.ring"


pr()

oTimeline9 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline9.AddInstant("X", "2025-10-22 08:00:00")
oTimeline9.AddInstant("Y", "2025-10-22 09:00:00")
oTimeline9.AddInstant("Target", "2025-10-22 10:00:00")
oTimeline9.AddInstant("Z", "2025-10-22 11:00:00")

# Find Target anywhere in timeline
Tmx13 = new stzTimex("{@Event(Target)}")

? Tmx13.MatchPartial(oTimeline9)
#--> TRUE (Target found at position 3)

pf()
