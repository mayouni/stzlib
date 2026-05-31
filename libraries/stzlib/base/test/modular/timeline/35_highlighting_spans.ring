# Narrative
# --------
# Highlighting spans
#
# Extracted from stztimelinetest.ring, block #35.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("PHASE2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("PHASE3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
}

? oTimeLine.VizFindSpan("PHASE2")
#-->
'                                              
             ╞══PHASE2═══╡                          
╞═══PHASE1═══╡           ╞═══PHASE3═══╡             
●────────────●███████████●────────────●──────────○─►
1           2-3         4-5           6             

╭────┬─────────────────────┬────────┬─────────────────╮
│ No │      Timepoint      │ Label  │   Description   │
├────┼─────────────────────┼────────┼─────────────────┤
│    │ 2024-01-01 00:00:00 │        │ Timeline start  │
│  1 │ 2024-01-01 00:00:00 │ PHASE1 │ Start of PHASE1 │
│  2 │ 2024-03-31 23:59:59 │ PHASE1 │ End of PHASE1   │
│  3 │ 2024-04-01 00:00:00 │ PHASE2 │ Start of PHASE2 │
│  4 │ 2024-06-30 23:59:59 │ PHASE2 │ End of PHASE2   │
│  5 │ 2024-07-01 00:00:00 │ PHASE3 │ Start of PHASE3 │
│  6 │ 2024-09-30 23:59:59 │ PHASE3 │ End of PHASE3   │
│    │ 2024-12-31 23:59:59 │        │ Timeline end    │
╰────┴─────────────────────┴────────┴─────────────────╯
'

pf()
# Executed in 0.16 second(s) in Ring 1.24
