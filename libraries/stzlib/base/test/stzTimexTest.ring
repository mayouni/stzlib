load "../stzbase.ring"

# stzTimex Examples - Demonstrating Time Pattern Matching

/*--- Example 1: Basic Instant Matching

pr()

# Validate a single timestamp

Tx = Tx("{@Instant(2025-10-22T14:30)}")
? Tx.Match( StzDateTimeQ("2025-10-22 14:30:00") )
#--> TRUE

pf()

/*--- Duration Constraints
*/
pr()

# Match spans with ranges and steps


oDur1 = new stzDuration("1 hour 30 minutes")
oDur2 = new stzDuration("1 hour 20 minutes")

Tx = new stzTimex("{@Duration(1h..2h:15min)}")

? Tx.Match(oDur1)
#--> TRUE (within range, on 15min step)

? Tx.Match(oDur2)
#--> FALSE (not on 15min step)

? @@NL(oTx.MatchedParts())
#-->
'
[
	[
		[ "type", "duration" ],
		[ "label", "" ],
		[
			"data",
			[
				[ "type", "duration" ],
				[ "label", "" ],
				[ "start", "" ],
				[ "end", "" ],
				[ "object", @noname ]
			]
		]
	]
]
'

pf()

#------------------------------------------------------------#
# Example 3: Event Sequences in Timeline
#------------------------------------------------------------#

? "┌─ Example 3: Event Sequences ─┐"

# Create a timeline with events
oTimeline = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline.AddPoint("Meeting", "2025-10-22 09:00:00")
oTimeline.AddSpan("Break", "2025-10-22 10:00:00", "2025-10-22 10:15:00")
oTimeline.AddPoint("Lunch", "2025-10-22 12:00:00")

# Pattern: Meeting -> short break -> Lunch (with alternation)
oTx = new stzTimex("{@Event(Meeting) -> @Duration(15m..30m) -> (@Event(Break)|@Event(Lunch))}")

? "Pattern: Meeting -> 15-30min duration -> (Break or Lunch)"
? "Match: " + oTx.Match(oTimeline)
#--> TRUE

? "Token breakdown:"
aTokens = oTx.TokensXT()
for i = 1 to len(aTokens)
	? "  " + i + ": " + @@(aTokens[i])
next
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Example 4: Negation Pattern
#------------------------------------------------------------#

? "┌─ Example 4: Negation - No Overtime ─┐"

# Ensure no duration exceeds 8 hours
oTimeline2 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline2.AddSpan("Work", "2025-10-22 09:00:00", "2025-10-22 17:00:00")

oTx = new stzTimex("{@!Duration(>8h)}")

? "Pattern: {@!Duration(>8h)} (no overtime)"
? "Testing 8-hour workday"
? "Match: " + oTx.Match(oTimeline2)
#--> TRUE (no duration exceeds 8h)

# Test with overtime
oTimeline3 = new stzTimeLine("2025-10-22", "2025-10-22")
oTimeline3.AddSpan("Work", "2025-10-22 09:00:00", "2025-10-22 19:00:00")

? "Testing 10-hour workday"
? "Match: " + oTx.Match(oTimeline3)
#--> FALSE (has overtime)
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Example 5: Cyclic Pattern - Weekly Meetings
#------------------------------------------------------------#

? "┌─ Example 5: Cyclic Pattern ─┐"

# Match recurring weekly standups
oCalendar = new stzCalendar("2025-10")
oCalendar.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

oTx = new stzTimex("{@Event(Standup)~Mon}")

? "Pattern: {@Event(Standup)~Mon} (every Monday)"
? "Testing October calendar with working days"
? "Calendar has: " + oCalendar.HowManyWorkingDays() + " working days"

# Would match if standups occur every Monday
? "Pattern explanation:"
aExplain = oTx.Explain()
for i = 1 to len(aExplain)
	? "  " + aExplain[i][1] + ": " + @@(aExplain[i][2])
next
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Example 6: Complex Nested Pattern
#------------------------------------------------------------#

? "┌─ Example 6: Project Phases ─┐"

# Pattern for multi-phase project: 2-4 phases, each 3-7 days
oProjectTimeline = new stzTimeLine("2025-10-01", "2025-10-31")
oProjectTimeline.AddSpan("Phase1", "2025-10-01", "2025-10-05")  # 5 days
oProjectTimeline.AddSpan("Phase2", "2025-10-06", "2025-10-10")  # 5 days
oProjectTimeline.AddSpan("Phase3", "2025-10-11", "2025-10-17")  # 7 days

oTx = new stzTimex("{@Sequence({@Instant(Start) -> @Duration(3d..7d)+ -> @Instant(End)})2-4}")

? "Pattern: 2-4 project phases, each 3-7 days"
? "Testing 3-phase project"
? "Match: " + oTx.Match(oProjectTimeline)

? "Tokens parsed: " + len(oTx.Tokens())
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Example 7: Set Constraints - Specific Days
#------------------------------------------------------------#

? "┌─ Example 7: Set Constraints ─┐"

# Match events only on specific days
oTx = new stzTimex("{@Event+ & @Frame({Mon;Wed;Fri})}")

? "Pattern: Events on Mon/Wed/Fri only"

# Create timeline with various events
oTimeline4 = new stzTimeLine("2025-10-20", "2025-10-24")
oTimeline4.AddPoint("Event1", "2025-10-20")  # Monday
oTimeline4.AddPoint("Event2", "2025-10-22")  # Wednesday
oTimeline4.AddPoint("Event3", "2025-10-24")  # Friday

? "Testing events on Mon, Wed, Fri"
? "Match: " + oTx.Match(oTimeline4)
#--> TRUE (all events on allowed days)
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Example 8: Debugging Mode
#------------------------------------------------------------#

? "┌─ Example 8: Debug Mode ─┐"

oTx = new stzTimex("{@Instant -> @Duration(~1h:unique)}")
oTx.EnableDebug()

? "Pattern with fuzzy duration and uniqueness"
? "Debug output shows parsing and matching steps..."

aData = [
	new stzDateTime("2025-10-22 09:00:00"),
	new stzDuration("55 minutes")
]

? "Match result: " + oTx.Match(aData)

? "Pattern structure:"
? @@NL(oTx.Explain())
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Example 9: Practical Use - Meeting Scheduler
#------------------------------------------------------------#

? "┌─ Example 9: Meeting Scheduler ─┐"

# Validate meeting schedule: start, 1h meeting, 30min break, 1h meeting
oSchedule = new stzTimeLine("2025-10-22", "2025-10-22")
oSchedule.AddPoint("Start", "2025-10-22 09:00:00")
oSchedule.AddSpan("Meeting1", "2025-10-22 09:00:00", "2025-10-22 10:00:00")
oSchedule.AddSpan("Break", "2025-10-22 10:00:00", "2025-10-22 10:30:00")
oSchedule.AddSpan("Meeting2", "2025-10-22 10:30:00", "2025-10-22 11:30:00")

oTx = new stzTimex("{@Instant(Start) -> @Duration(1h) -> @Duration(30m) -> @Duration(1h)}")

? "Pattern: Start -> 1h meeting -> 30m break -> 1h meeting"
? "Match: " + oTx.Match(oSchedule)

if oTx.Match(oSchedule)
	? "✓ Schedule is valid!"
	aParts = oTx.MatchedParts()
	? "Matched " + len(aParts) + " temporal elements"
else
	? "✗ Schedule doesn't match pattern"
ok
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Example 10: Integration with Calendar Constraints
#------------------------------------------------------------#

? "┌─ Example 10: Calendar Integration ─┐"

# Pattern: Events during business hours, no holidays
oCalendar2 = new stzCalendar([2025, 10])
oCalendar2.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
oCalendar2.SetBusinessHours("09:00:00", "17:00:00")
oCalendar2.AddHoliday("2025-10-05", "National Day")

oTx = new stzTimex("{@Event+ & @Frame(BusinessHours:!Holiday)}")

? "Pattern: Events in business hours, not on holidays"
? "Calendar:"
? "  Working days: Mon-Fri"
? "  Business hours: 09:00-17:00"
? "  Holidays: Oct 5"

? "This pattern would validate events against calendar constraints"
? "└────────────────────────────────────────┘" + NL

#------------------------------------------------------------#
# Summary
#------------------------------------------------------------#

? "╔═══════════════════════════════════════════════════╗"
? "║              Pattern Syntax Summary               ║"
? "╠═══════════════════════════════════════════════════╣"
? "║ @Instant(label)     - Point in time              ║"
? "║ @Duration(1h..2h)   - Time span with range       ║"
? "║ @Event(Meeting)     - Labeled temporal event     ║"
? "║ @Sequence(...)      - Ordered series             ║"
? "║ @Frame(context)     - Bounded time space         ║"
? "║                                                   ║"
? "║ Operators:                                        ║"
? "║   ->    Sequence (follows)                       ║"
? "║   |     Alternation (or)                         ║"
? "║   &     Overlap (during)                         ║"
? "║   !     Negation (not)                           ║"
? "║                                                   ║"
? "║ Quantifiers:                                      ║"
? "║   +     One or more                              ║"
? "║   *     Zero or more                             ║"
? "║   ?     Optional (0 or 1)                        ║"
? "║   m-n   Range                                    ║"
? "║   ~     Cyclic (repeating)                       ║"
? "║                                                   ║"
? "║ Constraints:                                      ║"
? "║   (1h..2h)      Range                            ║"
? "║   {Mon;Wed}     Set                              ║"
? "║   :15min        Step                             ║"
? "║   :unique       No duplicates                    ║"
? "╚═══════════════════════════════════════════════════╝"
