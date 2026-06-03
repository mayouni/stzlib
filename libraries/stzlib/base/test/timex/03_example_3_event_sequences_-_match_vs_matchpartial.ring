# Narrative
# --------
# Example 3: Event Sequences - Match vs MatchPartial
#
# Extracted from stztimextest.ring, block #3.

load "../../stzBase.ring"


pr()

oTimeline = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline.AddInstant("Meeting", "2025-10-22 09:00:00")
oTimeline.AddSpan("Break", "2025-10-22 10:00:00", "2025-10-22 10:15:00")
oTimeline.AddInstant("Lunch", "2025-10-22 12:00:00")

# Pattern: Meeting -> any gaps -> Break
Tmx1 = new stzTimex("{@Event(Meeting) -> @Duration* -> @Event(Break)}")

# Match (exact - must consume all data):
? Tmx1.Match(oTimeline)
#--> FALSE (pattern stops at Break, but Lunch remains)

# MatchPartial (finds pattern anywhere):
? Tmx1.MatchPartial(oTimeline)
#--> TRUE (Meeting->Break sequence exists)

pf()
