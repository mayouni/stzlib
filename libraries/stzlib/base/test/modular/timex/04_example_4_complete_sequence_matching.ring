# Narrative
# --------
# Example 4: Complete Sequence Matching
#
# Extracted from stztimextest.ring, block #4.

load "../../../stzBase.ring"


pr()

oTimeline2 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline2.AddInstant("Start", "2025-10-22 09:00:00")
oTimeline2.AddSpan("Work", "2025-10-22 09:00:00", "2025-10-22 17:00:00")
oTimeline2.AddInstant("End", "2025-10-22 17:00:00")

# Pattern matches entire timeline
Tmx2 = new stzTimex("{@Event(Start) -> @Duration* -> @Event(Work) -> @Duration* -> @Event(End)}")

? Tmx2.Match(oTimeline2)
#--> TRUE (exact match - entire timeline consumed)

pf()
