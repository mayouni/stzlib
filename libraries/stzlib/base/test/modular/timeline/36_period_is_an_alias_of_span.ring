# Narrative
# --------
# #NOTE Period is an alias of Span
#
# Extracted from stztimelinetest.ring, block #36.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddPeriods([
		[ "SUCCESS", "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
		[ "FAILURE", "2024-04-01 00:00:00", "2024-06-30 23:59:59" ],
		[ "SUCCESS", "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	])

	# Finding the occurrences of a given Period by lablel
	# and returning the occurences datetimes

	? @@(FindPeriod("SUCCESS"))
	#--> [
	# 	[ "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
	# 	[ "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	# ]

	# The same as above along with the positions on the timeline

	? @@(FindPeriodXT("SUCCESS")) + NL
	#--> [
	# 	[ "1", [ "2024-01-01 00:00:00", "2024-03-31 23:59:59" ] ],
	# 	[ "3", [ "2024-07-01 00:00:00", "2024-09-30 23:59:59" ] ]
	# ]

	# Higligting the Periods visually on the timeline
	? VizFindPeriod("SUCCESS")
}
#-->
'
             ╞══FAILURE══╡                          
╞══SUCCESS═══╡           ╞══SUCCESS═══╡             
●████████████●───────────●████████████●──────────○─►
1           2-3         4-5           6             

╭────┬─────────────────────┬─────────┬──────────────────╮
│ No │      Timepoint      │  Label  │   Description    │
├────┼─────────────────────┼─────────┼──────────────────┤
│    │ 2024-01-01 00:00:00 │         │ Timeline start   │
│  1 │ 2024-01-01 00:00:00 │ SUCCESS │ Start of SUCCESS │
│  2 │ 2024-03-31 23:59:59 │ SUCCESS │ End of SUCCESS   │
│  3 │ 2024-04-01 00:00:00 │ FAILURE │ Start of FAILURE │
│  4 │ 2024-06-30 23:59:59 │ FAILURE │ End of FAILURE   │
│  5 │ 2024-07-01 00:00:00 │ SUCCESS │ Start of SUCCESS │
│  6 │ 2024-09-30 23:59:59 │ SUCCESS │ End of SUCCESS   │
│    │ 2024-12-31 23:59:59 │         │ Timeline end     │
╰────┴─────────────────────┴─────────┴──────────────────╯
'

pf()
# Executed in 0.16 second(s) in Ring 1.24
