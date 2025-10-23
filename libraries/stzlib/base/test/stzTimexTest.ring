load "../stzbase.ring"

# stzTimex Test Suite - Updated for Match/MatchPartial semantics

/*--- Example 1: Basic Instant Matching

pr()

# Match single timestamp

Tx = Tx("{@Instant}")
? Tx.Match(StzDateTimeQ("2025-10-22 14:30:00"))
#--> TRUE (exact match)

? Tx.MatchPartial(StzDateTimeQ("2025-10-22 14:30:00"))
#--> TRUE (partial also works for single item)

pf()

/*--- Example 2: Duration Constraints with Steps

pr()

oDur1 = new stzDuration("1 hour 30 minutes")  # 90 minutes
oDur2 = new stzDuration("1 hour 20 minutes")  # 80 minutes

Tx = new stzTimex("{@Duration(1h..2h:15min)}")

? Tx.Match(oDur1)
#--> TRUE (90min is in range and on 15min boundary)

? Tx.Match(oDur2)
#--> FALSE (80min not on 15min step: 60, 75, 90, 105, 120)

pf()

/*--- Example 3: Event Sequences - Match vs MatchPartial

pr()

oTimeline = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline.AddPoint("Meeting", "2025-10-22 09:00:00")
oTimeline.AddSpan("Break", "2025-10-22 10:00:00", "2025-10-22 10:15:00")
oTimeline.AddPoint("Lunch", "2025-10-22 12:00:00")

# Pattern: Meeting -> any gaps -> Break
Tx1 = new stzTimex("{@Event(Meeting) -> @Duration* -> @Event(Break)}")

# Match (exact - must consume all data):
? Tx1.Match(oTimeline)
#--> FALSE (pattern stops at Break, but Lunch remains)

# MatchPartial (finds pattern anywhere):
? Tx1.MatchPartial(oTimeline)
#--> TRUE (Meeting->Break sequence exists)

pf()

/*--- Example 4: Complete Sequence Matching

pr()

oTimeline2 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline2.AddPoint("Start", "2025-10-22 09:00:00")
oTimeline2.AddSpan("Work", "2025-10-22 09:00:00", "2025-10-22 17:00:00")
oTimeline2.AddPoint("End", "2025-10-22 17:00:00")

# Pattern matches entire timeline
Tx2 = new stzTimex("{@Event(Start) -> @Duration* -> @Event(Work) -> @Duration* -> @Event(End)}")

? Tx2.Match(oTimeline2)
#--> TRUE (exact match - entire timeline consumed)

pf()

/*--- Example 5: Gap Duration Constraints

pr()

oTimeline3 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline3.AddPoint("A", "2025-10-22 09:00:00")
oTimeline3.AddPoint("B", "2025-10-22 09:30:00")  # 30min gap
oTimeline3.AddPoint("C", "2025-10-22 10:00:00")  # 30min gap

# Match events with 30min gaps
Tx3 = new stzTimex("{@Event(A) -> @Duration(30m) -> @Event(B)}")

? Tx3.MatchPartial(oTimeline3)
#--> TRUE (finds A->30min->B)

# Try with wrong gap duration
Tx4 = new stzTimex("{@Event(A) -> @Duration(1h) -> @Event(B)}")

? Tx4.MatchPartial(oTimeline3) #ERR
#--> FALSE (gap is 30min, not 1h)

pf()

/*--- Example 6: Alternation Patterns

pr()

oTimeline4 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline4.AddPoint("Meeting", "2025-10-22 09:00:00")
oTimeline4.AddSpan("Coffee", "2025-10-22 10:00:00", "2025-10-22 10:15:00")
oTimeline4.AddPoint("Lunch", "2025-10-22 12:00:00")

# Match Meeting followed by Coffee OR Lunch
Tx5 = new stzTimex("{@Event(Meeting) -> @Duration* -> (@Event(Coffee)|@Event(Lunch))}")

? Tx5.MatchPartial(oTimeline4)
#--> TRUE (Meeting->Coffee path matches)

pf()

/*--- Example 7: Event Span Duration Constraints

pr()

oTimeline5 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline5.AddSpan("Session", "2025-10-22 09:00:00", "2025-10-22 10:00:00")  # 60min

# Match event that lasts exactly 1 hour
Tx6 = new stzTimex("{@Event(Session:1h)}")

? Tx6.Match(oTimeline5) #ERR
#--> TRUE (Session span is 60 minutes)

# Try with wrong duration
Tx7 = new stzTimex("{@Event(Session:30m)}")

? Tx7.Match(oTimeline5)
#--> FALSE (Session is 60min, not 30min)

pf()

/*--- Example 8: Quantifiers - Zero or More

pr()

oTimeline6 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline6.AddPoint("Start", "2025-10-22 09:00:00")
oTimeline6.AddPoint("End", "2025-10-22 17:00:00")

# Match Start and End with any number of gaps between
Tx8 = new stzTimex("{@Event(Start) -> @Duration* -> @Event(End)}")

? Tx8.Match(oTimeline6)
#--> TRUE (@Duration* matches 1 gap)

pf()

/*--- Example 9: Adjacent Events (No Gaps)

pr()

oTimeline7 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline7.AddSpan("Session1", "2025-10-22 09:00:00", "2025-10-22 10:00:00")
oTimeline7.AddSpan("Session2", "2025-10-22 10:00:00", "2025-10-22 11:00:00")

# Match adjacent events
Tx9 = new stzTimex("{@Event(Session1) -> @Event(Session2)}")

? Tx9.Match(oTimeline7)
#--> TRUE (events are adjacent, no gap required)

pf()

/*--- Example 10: Pattern Debugging

pr()

oTimeline8 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline8.AddPoint("A", "2025-10-22 09:00:00")
oTimeline8.AddPoint("B", "2025-10-22 10:00:00")
oTimeline8.AddPoint("C", "2025-10-22 11:00:00")

Tx10 = new stzTimex("{@Event(A) -> @Duration* -> @Event(C)}")
//Tx10.EnableDebug()

? Tx10.MatchPartial(oTimeline8) #ERR
#--> TRUE (with detailed trace)


pf()

/*--- Example 11: Real-World Meeting Scheduler

pr()

oSchedule = new stzTimeLine("2025-10-22", "2025-10-22")
oSchedule.AddPoint("DayStart", "2025-10-22 08:00:00")
oSchedule.AddSpan("Standup", "2025-10-22 09:00:00", "2025-10-22 09:15:00")
oSchedule.AddSpan("DeepWork", "2025-10-22 09:30:00", "2025-10-22 12:00:00")
oSchedule.AddSpan("Lunch", "2025-10-22 12:00:00", "2025-10-22 13:00:00")

# Validate standup happens after day start
Tx11 = new stzTimex("{@Event(DayStart) -> @Duration* -> @Event(Standup)}")

? Tx11.MatchPartial(oSchedule)
#--> TRUE (pattern exists in schedule)

# Check for deep work session (2+ hours)
Tx12 = new stzTimex("{@Event(DeepWork:2h..4h)}")

? Tx12.MatchPartial(oSchedule) #ERR
#--> TRUE (DeepWork is 2.5 hours)

pf()

/*--- Example 12: Finding Patterns Across Timeline

pr()

oTimeline9 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline9.AddPoint("X", "2025-10-22 08:00:00")
oTimeline9.AddPoint("Y", "2025-10-22 09:00:00")
oTimeline9.AddPoint("Target", "2025-10-22 10:00:00")
oTimeline9.AddPoint("Z", "2025-10-22 11:00:00")

# Find Target anywhere in timeline
Tx13 = new stzTimex("{@Event(Target)}")

? Tx13.MatchPartial(oTimeline9)
#--> TRUE (Target found at position 3)

pf()

/*--- Example 13: Pattern Explanation

pr()

Tx14 = new stzTimex("{@Event(Meeting) -> @Duration(30m..1h) -> @Event(Break)}")

? "Pattern structure:"
? @@NL(Tx14.Explain())
#--> Shows tokens, constraints, and semantics

pf()
