# Narrative
# --------
# Example 6: Alternation Patterns
#
# Extracted from stztimextest.ring, block #6.

load "../../stzBase.ring"


pr()

oTimeline4 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline4.AddInstant("Meeting", "2025-10-22 09:00:00")
oTimeline4.AddSpan("Coffee", "2025-10-22 10:00:00", "2025-10-22 10:15:00")
oTimeline4.AddInstant("Lunch", "2025-10-22 12:00:00")

# Match Meeting followed by Coffee OR Lunch
Tmx5 = new stzTimex("{@Event(Meeting) -> @Duration* -> (@Event(Coffee)|@Event(Lunch))}")

? Tmx5.MatchPartial(oTimeline4)
#--> TRUE (Meeting->Coffee path matches)

pf()
