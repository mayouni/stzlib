# Narrative
# --------
# Custom width display
#
# Extracted from stztimelinetest.ring, block #33.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("Q1", "2024-03-31 23:59:59")
	AddPoint("Q2", "2024-06-30 23:59:59")
	AddPoint("Q3", "2024-09-30 23:59:59")
}

? oTimeLine.ToStringXT([ :Width = 30 ])
#-->
#       Q1     Q2     Q3        
# │──────●──────●──────●────────○─►
#        1      2      3   
#
# ╭────┬─────────────────────┬───────┬─────────────╮
# │ No │      Timepoint      │ Label │ Description │
# ├────┼─────────────────────┼───────┼─────────────┤
# │  1 │ 2024-03-31 23:59:59 │ Q1    │ Q1 event    │
# │  2 │ 2024-06-30 23:59:59 │ Q2    │ Q2 event    │
# │  3 │ 2024-09-30 23:59:59 │ Q3    │ Q3 event    │
# ╰────┴─────────────────────┴───────┴─────────────╯

pf()
# Executed in 0.07 second(s) in Ring 1.24
