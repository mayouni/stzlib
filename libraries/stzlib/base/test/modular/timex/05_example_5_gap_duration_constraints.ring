# Narrative
# --------
# Example 5: Gap Duration Constraints
#
# Extracted from stztimextest.ring, block #5.

load "../../../stzBase.ring"


pr()

oTimeline3 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline3.AddInstant("A", "2025-10-22 09:00:00")
oTimeline3.AddInstant("B", "2025-10-22 09:30:00")  # 30min gap
oTimeline3.AddInstant("C", "2025-10-22 10:00:00")  # 30min gap

# Match events with 30min gaps
Tmx3 = new stzTimex("{@Event(A) -> @Duration(30m) -> @Event(B)}")

? Tmx3.MatchPartial(oTimeline3)
#--> TRUE (finds A->30min->B)

# Try with wrong gap duration
Tmx4 = new stzTimex("{@Event(A) -> @Duration(1h) -> @Event(B)}")

? Tmx4.MatchPartial(oTimeline3)
#--> FALSE (gap is 30min, not 1h)

pf()
