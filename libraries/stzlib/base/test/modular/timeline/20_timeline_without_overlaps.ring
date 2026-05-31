# Narrative
# --------
# Timeline without overlaps
#
# Extracted from stztimelinetest.ring, block #20.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
}

? @@NL( oTimeLine.Spans() ) + NL
#--> [
#	[
#		"Q1",
#		"2024-01-01 00:00:00",
#		"2024-03-31 23:59:59"
#	],
#	[
#		"Q2",
#		"2024-04-01 00:00:00",
#		"2024-06-30 23:59:59"
#	],
#	[
#		"Q3",
#		"2024-07-01 00:00:00",
#		"2024-09-30 23:59:59"
#	]
# ]

? oTimeLine.HasOverlaps()
#--> FALSE

? @@(oTimeLine.OverlappingSpans())
#--> [ ]

oTimeLine.Show()
#-->
'
             ╞════Q2═════╡                          
╞═════Q1═════╡           ╞═════Q3═════╡             
●────────────●───────────●────────────●────────────○─►
1           2-3         4-5           6             

╭────┬─────────────────────┬───────┬────────────────╮
│ No │      Timepoint      │ Label │  Description   │
├────┼─────────────────────┼───────┼────────────────┤
│    │ 2024-01-01 00:00:00 │       │ Timeline start │
│  1 │ 2024-01-01 00:00:00 │ Q1    │ Start of Q1    │
│  2 │ 2024-03-31 23:59:59 │ Q1    │ End of Q1      │
│  3 │ 2024-04-01 00:00:00 │ Q2    │ Start of Q2    │
│  4 │ 2024-06-30 23:59:59 │ Q2    │ End of Q2      │
│  5 │ 2024-07-01 00:00:00 │ Q3    │ Start of Q3    │
│  6 │ 2024-09-30 23:59:59 │ Q3    │ End of Q3      │
│    │ 2024-12-31 23:59:59 │       │ Timeline end   │
╰────┴─────────────────────┴───────┴────────────────╯
'

# NOTE: As you can see, the start of the timeline — usually marked with "|" — 
# is now displayed as "●" because it coincides with the beginning of the Q1 span.  
#
# Both the start of the timeline and the start of Q1 share the same datetime in the table.  
# However, the start of the timeline has no numeric order, since, like the end of the timeline, 
# it simply acts as a boundary marker rather than a data point.  
#
# The start or end of a timeline may appear as "●" only when a defined point or span 
# (added via `AddPoint()` or `AddSpan()`) starts or ends exactly at those boundaries.  
#
# When the end of the timeline has no explicitly defined event, it is still worth noting — 
# it usually represents an *implicit milestone* of the timeline, illustrated by the symbol "○─►".

pf()
# Executed in 0.15 second(s) in Ring 1.24

#------------------#
#  Gap Analysis    #
#------------------#
