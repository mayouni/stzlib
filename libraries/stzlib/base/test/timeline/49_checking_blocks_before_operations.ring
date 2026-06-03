# Narrative
# --------
# Checking blocks before operations
#
# Extracted from stztimelinetest.ring, block #49.

load "../../stzBase.ring"


pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeline.AddBlockedSpan("BLACKOUT", "2024-08-01 00:00:00", "2024-08-08 23:59:59")

if oTimeline.IsBlocked("2024-08-05 14:30:00")
	? "Cannot add event during blackout"
ok
#--> Cannot add event during blackout

if oTimeline.IsSectionBlocked("2024-08-07", "2024-08-10")
	? "Span partially blocked"
ok
#--> Span partially blocked

pf()
# Executed in 0.01 second(s) in Ring 1.24
