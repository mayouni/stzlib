# Narrative
# --------
# Finding and Highlighting specific element
#
# Extracted from stztimelinetest.ring, block #34.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddMoments([
		[ "EVENT_1", "2024-02-15 10:00:00" ],
		[ "EVENT_2", "2024-05-15 10:00:00" ],
		[ "EVENT_1", "2024-08-15 10:00:00" ]
	])

	# Finding the occurrences of a given moment by lablel
	# and returning the occurences datetimes

	? @@(FindMoment("EVENT_1"))
	#--> [ "2024-02-15 10:00:00", "2024-08-15 10:00:00" ]

	# The same as above along with the positions on the timeline

	? @@(FindMomentXT("EVENT_1")) + NL
	#--> [ [ "1", "2024-02-15 10:00:00" ], [ "3", "2024-08-15 10:00:00" ] ]

	# Higligting the moments visually on the timeline
	? VizFindMoment("EVENT_1")
}
#-->
'
    EVENT_1     EVENT_2      EVENT_1                
│──────█───────────●────────────█───────────────────○─►
       1           2            3                   

╭────┬─────────────────────┬─────────┬────────────────╮
│ No │      Timepoint      │  Label  │  Description   │
├────┼─────────────────────┼─────────┼────────────────┤
│    │ 2024-01-01 00:00:00 │         │ Timeline start │
│  1 │ 2024-02-15 10:00:00 │ EVENT_1 │ EVENT_1 event  │
│  2 │ 2024-05-15 10:00:00 │ EVENT_2 │ EVENT_2 event  │
│  3 │ 2024-08-15 10:00:00 │ EVENT_1 │ EVENT_1 event  │
│    │ 2024-12-31 23:59:59 │         │ Timeline end   │
╰────┴─────────────────────┴─────────┴────────────────╯
'

pf()
# Executed in 0.09 second(s) in Ring 1.24
