# Narrative
# --------
# Example 8: Quantifiers - Zero or More
#
# Extracted from stztimextest.ring, block #8.

load "../../../stzBase.ring"


pr()

oTimeline6 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline6.AddInstant("Start", "2025-10-22 09:00:00")
oTimeline6.AddInstant("End", "2025-10-22 17:00:00")

# Match Start and End with any number of gaps between
Tmx8 = new stzTimex("{@Event(Start) -> @Duration* -> @Event(End)}")

? Tmx8.Match(oTimeline6)
#--> TRUE (@Duration* matches 1 gap)

pf()
