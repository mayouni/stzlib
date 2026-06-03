# Narrative
# --------
# Multiple blocked periods
#
# Extracted from stztimelinetest.ring, block #48.

load "../../stzBase.ring"


pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-12-31")

oTimeline.AddBlockedSpan("Q2_FREEZE", "2024-04-01", "2024-06-30")
oTimeline.AddBlockedSpan("HOLIDAY", "2024-12-20", "2024-12-31")

oTimeline.AddSpan("PROJECT", "2024-05-01", "2024-05-15")
#--> ERROR: Span 'PROJECT' overlaps with a blocked span 

oTimeline.AddSpan("PLANNING", "2024-07-01", "2024-07-15") # OK

pf()
