# Narrative
# --------
# Simple display (without configuration)
#
# Extracted from stztimelinetest.ring, block #32.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("KICKOFF", "2024-03-01 00:00:00")
	AddSpan("PREP", "2024-05-01 00:00:00", "2024-08-01 00:00:00")
	AddPoint("CLOSING", "2024-11-01 00:00:00")
}

# Displaying the timeline along with the info tbale

oTimeLine.Show()
#-->
#                                                    
#       KICKOFF    ╞════PREP════╡        CLOSING      
# |────────●───────●────────────●───────────●──────○─►
#          1       2            3           4         
# 
# ╭────┬─────────────────────┬─────────┬────────────────╮
# │ No │      Timepoint      │  Label  │  Description   │
# ├────┼─────────────────────┼─────────┼────────────────┤
# │    │ 2024-01-01 00:00:00 │         │ Timeline start │
# │  1 │ 2024-03-01 00:00:00 │ KICKOFF │ KICKOFF event  │
# │  2 │ 2024-05-01 00:00:00 │ PREP    │ Start of PREP  │
# │  3 │ 2024-08-01 00:00:00 │ PREP    │ End of PREP    │
# │  4 │ 2024-11-01 00:00:00 │ CLOSING │ CLOSING event  │
# │    │ 2024-12-31 23:59:59 │         │ Timeline end   │
# ╰────┴─────────────────────┴─────────┴────────────────╯
 
# If you want to see the timeline without the table

oTimeLine.ShowShort() # Same as ShowXT([ :ShowTable = FALSE ])
#-->
#                                                     
#       KICKOFF    ╞════PREP════╡        CLOSING      
# │────────●───────●────────────●───────────●────────○─►
#          1       2            3           4         

# You can display a statistical legend instead of the norma table

oTimeLine.ShowXT([ :TableType = :Statistical ]) # VS :TableType = :Normal
#-->
#                                                     
#       KICKOFF    ╞════PREP════╡        CLOSING      
# │────────●───────●────────────●───────────●────────○─►
#          1       2            3           4         
# 
# ╭────────────────────┬────────────────╮
# │       Metric       │     Value      │
# ├────────────────────┼────────────────┤
# │ Total Points       │              2 │
# │ Total Spans        │              1 │
# │ Timeline Duration  │ 1 year         │
# │ Coverage           │ 25%            │
# │ Longest Span       │ PREP (92 days) │
# │ Gaps Between Spans │              0 │
# │ Overlapping Spans  │              0 │
# ╰────────────────────┴────────────────╯

# You can get the stats as date:
? @@NL( oTimeLine.Stats() )
#--> [
#	[ "metric", "value" ],

#	[ "Total Points", 2 ],
#	[ "Total Spans", 1 ],
#	[ "Timeline Duration", "1 year" ],
#	[ "Coverage", "25%" ],
#	[ "Longest Span", "PREP (92 days)" ],
#	[ "Gaps Between Spans", 0 ],
#	[ "Overlapping Spans", 0 ]
# ]

#TODO: May it's better Stats() returns the values in number formats not in natural text...

pf()
# Executed in 0.12 second(s) in Ring 1.24
