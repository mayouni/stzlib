# Narrative
# --------
# Complex timeline with blocked regions and points
#
# Extracted from stztimelinetest.ring, block #53.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	# Regular spans

	AddSpan("SPAN1", "2024-01-01", "2024-06-30")
	AddSpan("SPAN2", "2024-03-01", "2024-09-30")
	AddSpan("SPAN3", "2024-05-01", "2024-12-31")

	# Blocked spans (maintenance windows, freezes)

	AddBlockedSpan("FREEZE1", "2024-01-20", "2024-02-28")
	AddBlockedSpan("FREEZE2", "2024-07-01", "2024-07-15")
	AddBlockedSpan("MAINTENANCE", "2024-11-15", "2024-11-20")

	# Blocked individual points

	AddBlockedPoint("2024-03-15 10:30:00")
	AddBlockedPoint("2024-06-15 14:00:00")
	AddBlockedPoint("2024-10-05 09:00:00")

	# Regular points

	AddPoint("KICKOFF", "2024-01-05 09:00:00")
	//oTimeLine.AddPoint("REVIEW1", "2024-03-15 10:30:00")  # Will error - blocked point
	AddPoint("MEETING", "2024-05-10 11:00:00")
	//oTimeLine.AddPoint("DEMO", "2024-06-15 14:00:00")     # Will error - blocked point
	AddPoint("SYNC", "2024-08-20 15:00:00")
	AddPoint("FINAL", "2024-11-10 10:00:00")

	Show()
}
#-->
'
                ╞=============SPAN3==============╡ 
         ╞===========SPAN2============╡             
╞=========SPAN1SPAN3=====╡                      SPAN
●●─XXXXXX●─X─────●●────X─●XX────●─────●X───●XX────●○─►
12       3       45      6      7     8    9     10 

╭────┬─────────────────────┬─────────┬────────────────╮
│ No │      Timepoint      │  Label  │  Description   │
├────┼─────────────────────┼─────────┼────────────────┤
│    │ 2024-01-01 00:00:00 │         │ Timeline start │
│  1 │ 2024-01-01 00:00:00 │ SPAN1   │ Start of SPAN1 │
│  2 │ 2024-01-05 09:00:00 │ KICKOFF │ KICKOFF event  │
│  3 │ 2024-03-01 00:00:00 │ SPAN2   │ Start of SPAN2 │
│  4 │ 2024-05-01 00:00:00 │ SPAN3   │ Start of SPAN3 │
│  5 │ 2024-05-10 11:00:00 │ MEETING │ MEETING event  │
│  6 │ 2024-06-30 00:00:00 │ SPAN1   │ End of SPAN1   │
│  7 │ 2024-08-20 15:00:00 │ SYNC    │ SYNC event     │
│  8 │ 2024-09-30 00:00:00 │ SPAN2   │ End of SPAN2   │
│  9 │ 2024-11-10 10:00:00 │ FINAL   │ FINAL event    │
│ 10 │ 2024-12-31 00:00:00 │ SPAN3   │ End of SPAN3   │
│    │ 2024-12-31 23:59:59 │         │ Timeline end   │
╰────┴─────────────────────┴─────────┴────────────────╯
'

pf()
# Executed in 0.35 second(s) in Ring 1.24
