# Narrative
# --------
# Example 7: Event Span Duration Constraints
#
# Extracted from stztimextest.ring, block #7.

load "../../../stzBase.ring"


pr()

oTimeline5 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline5.AddSpan("Session", "2025-10-22 09:00:00", "2025-10-22 10:00:00")  # 60min

# Match event that lasts exactly 1 hour
Tmx6 = new stzTimex("{@Event(Session:1h)}")

? Tmx6.Match(oTimeline5)
#--> TRUE (Session span is 60 minutes)

# Try with wrong duration
Tmx7 = new stzTimex("{@Event(Session:30m)}")

? Tmx7.Match(oTimeline5)
#--> FALSE (Session is 60min, not 30min)

pf()
