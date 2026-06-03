# Narrative
# --------
# Removing points
#
# Extracted from stztimelinetest.ring, block #6.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoints([ 
		[ "EVENT1", "2024-03-15 10:00:00" ],
		[ "EVENT1", "2024-05-16 14:30:00" ],
		[ "EVENT1", "2024-08-17 09:00:00" ]
	])
}

oTimeLine.Show()
#-->
'
        EVENT1  EVENT1       EVENT1                 
|──────────●───────●────────────●────────────────○─►
           1       2            3                 

╭────┬─────────────────────┬────────┬────────────────╮
│ No │      Timepoint      │ Label  │  Description   │
├────┼─────────────────────┼────────┼────────────────┤
│    │ 2024-01-01 00:00:00 │        │ Timeline start │
│  1 │ 2024-03-15 10:00:00 │ EVENT1 │ EVENT1 event   │
│  2 │ 2024-05-16 14:30:00 │ EVENT1 │ EVENT1 event   │
│  3 │ 2024-08-17 09:00:00 │ EVENT1 │ EVENT1 event   │
│    │ 2024-12-31 23:59:59 │        │ Timeline end   │
╰────┴─────────────────────┴────────┴────────────────╯
'

? oTimeLine.CountPoints()
#--> 3

oTimeLine.RemovePoint("EVENT1")
oTimeLine.RemovePoint("EVENT1")
oTimeLine.RemovePoint("EVENT1")

? oTimeLine.CountPoints()
#--> 0

? oTimeLine.HasPoint("EVENT2")
#--> FALSE

oTimeLine.Show()
#-->
# |────────────────────────────────────────────────○─►
#
# ╭────┬─────────────────────┬───────┬────────────────╮
# │ No │      Timepoint      │ Label │  Description   │
# ├────┼─────────────────────┼───────┼────────────────┤
# │    │ 2024-01-01 00:00:00 │       │ Timeline start │
# │    │ 2024-12-31 23:59:59 │       │ Timeline end   │
# ╰────┴─────────────────────┴───────┴────────────────╯

pf()
# Executed in 0.09 second(s) in Ring 1.24
