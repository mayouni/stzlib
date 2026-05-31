# Narrative
# --------
# Example 11: Real-World Meeting Scheduler
#
# Extracted from stztimextest.ring, block #11.

load "../../../stzBase.ring"


pr()

oSchedule = new stzTimeLine("2025-10-22", "2025-10-22")
oSchedule.AddInstant("DayStart", "2025-10-22 08:00:00")
oSchedule.AddSpan("Standup", "2025-10-22 09:00:00", "2025-10-22 09:15:00")
oSchedule.AddSpan("DeepWork", "2025-10-22 09:30:00", "2025-10-22 12:00:00")
oSchedule.AddSpan("Lunch", "2025-10-22 12:00:00", "2025-10-22 13:00:00")

# Validate standup happens after day start
Tmx11 = new stzTimex("{@Event(DayStart) -> @Duration* -> @Event(Standup)}")

? Tmx11.MatchPartial(oSchedule)
#--> TRUE (pattern exists in schedule)

# Check for deep work session (2+ hours)
Tmx12 = new stzTimex("{@Event(DeepWork:2h..4h)}")

? Tmx12.MatchPartial(oSchedule)
#--> TRUE (DeepWork is 2.5 hours)

pf()
