# Narrative
# --------
# Example 10: Pattern Debugging
#
# Extracted from stztimextest.ring, block #10.

load "../../stzBase.ring"


pr()

oTimeline8 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline8.AddInstant("A", "2025-10-22 09:00:00")
oTimeline8.AddInstant("B", "2025-10-22 10:00:00")
oTimeline8.AddInstant("C", "2025-10-22 11:00:00")

Tmx10 = new stzTimex("{@Event(A) -> @Duration* -> @Event(C)}")
Tmx10.EnableDebug()

? Tmx10.MatchPartial(oTimeline8)
#--> TRUE (with detailed trace)
'
Token 1 (type=event, label=A): trying 1 matches starting at data position 1
  Attempt 1: checking data[1] type=instant, label=A
CheckConstraints: type=instant, label=A, constraints=0
Token 2 (type=duration, label=): trying 2 matches starting at data position 2
  Attempt 1: checking data[2] type=duration, label=
CheckConstraints: type=duration, label=, constraints=0
  Attempt 2: checking data[3] type=instant, label=B
  Attempt 2: checking data[4] type=duration, label=
CheckConstraints: type=duration, label=, constraints=0
Token 3 (type=event, label=C): trying 1 matches starting at data position 5
  Attempt 1: checking data[5] type=instant, label=C
CheckConstraints: type=instant, label=C, constraints=0
'

pf()
