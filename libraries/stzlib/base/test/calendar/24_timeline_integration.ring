# Narrative
# --------
# #  TimeLine Integration  #
#
# Extracted from stzcalendartest.ring, block #24.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#------------------------#

pr()

oCal = new stzCalendar([ 2024, 10 ])

oTimeline = new stzTimeLine("2024-10-01", "2024-10-31")
oTimeline.AddPoint("STANDUP", "2024-10-10 09:00:00")
oTimeline.AddSpan("PROJECT", "2024-10-15", "2024-10-20")

oCal.MarkTimeline(oTimeline)
oCal.Show()  # Events appear as ● and ▬
#-->
'
                October 2024
╭─────────────────────────────────────────╮
│ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
├─────────────────────────────────────────┤
│        1     2     3     4    ░░    ░░  │
│  7     8     9    ●10    11   ░░    ░░  │
│  14   ▬15   ▬16   ▬17   ▬18   ▬░░   ▬░░ │
│  21    22    23    24    25   ░░    ░░  │
│  28    29    30    31                   │
╰─────────────────────────────────────────╯

Legend:
  ░ = Weekend
  ● = Timeline-event
  ▬ = Timeline-span

╭───────────────────────┬─────────────────────╮
│        Metric         │        Value        │
├───────────────────────┼─────────────────────┤
│ Total Days            │                  31 │
│ Working Days          │                  23 │
│ Weekend Days          │                   8 │
│ Holidays              │                   0 │
│ Total Available Hours │                 184 │
│ Average Hours Per Day │                   8 │
│ First Working Day     │ 2024-10-01          │
│ Last Working Day      │ 2024-10-31          │
│ Business Hours        │ 09:00:00 - 17:00:00 │
╰───────────────────────┴─────────────────────╯
'

? oCal.ConflictsWith(oTimeline)
#--> TRUE (events hit holidays/weekends)

? @@NL(oCal.TimelineEvents())    # Count events, analyze
#-->
'
[
	[
		"points",
		[
			[ "STANDUP", "2024-10-10 09:00:00" ]
		]
	],
	[
		"spans",
		[
			[
				"PROJECT",
				"2024-10-15 00:00:00",
				"2024-10-20 00:00:00"
			]
		]
	]
]
'

pf()
# Executed in 0.61 second(s) in Ring 1.24
