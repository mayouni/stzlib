# Narrative
# --------
# Example 9: Adjacent Events (No Gaps)
#
# Extracted from stztimextest.ring, block #9.

load "../../stzBase.ring"


pr()

oTimeline7 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline7.AddSpan("Session1", "2025-10-22 09:00:00", "2025-10-22 10:00:00")
oTimeline7.AddSpan("Session2", "2025-10-22 10:00:00", "2025-10-22 11:00:00")

# Match adjacent events
Tmx9 = new stzTimex("{@Event(Session1) -> @Event(Session2)}")

? Tmx9.Match(oTimeline7)
#--> TRUE (events are adjacent, no gap required)

pf()
