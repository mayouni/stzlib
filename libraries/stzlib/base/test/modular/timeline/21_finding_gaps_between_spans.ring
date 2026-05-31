# Narrative
# --------
# Finding gaps between spans
#
# Extracted from stztimelinetest.ring, block #21.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-02-15 23:59:59")
	AddSpan("PHASE2", "2024-03-01 00:00:00", "2024-04-15 23:59:59")
	AddSpan("PHASE3", "2024-05-01 00:00:00", "2024-06-30 23:59:59")
}

? @@NL( oTimeLine.Gaps() )
#--> [
#     [:After = "PHASE1", :Before = "PHASE2", :Duration = 1209600],
#     [:After = "PHASE2", :Before = "PHASE3", :Duration = 1296000]
# ]

oTimeLine.ShowShort()
#-->
'
╞PHASE1╡ ╞═════╡ ╞PHASE3═╡                          
●──────●─●─────●─●───────●─────────────────────────○─►
1      2 3     4 5       6                          
'

pf()
# Executed in 0.08 second(s) in Ring 1.24
