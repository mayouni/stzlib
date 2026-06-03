# Narrative
# --------
# Managing uncovered periods in timeline
#
# Extracted from stztimelinetest.ring, block #23.

load "../../stzBase.ring"

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpan("BUSY", "2024-03-01", "2024-05-31")
	AddSpan("BUSY", "2024-04-01", "2024-06-30")
	AddSpan("BUSY", "2024-08-01", "2024-09-20")

	AddMoment('MMM', "2024-08-01")

	ShowUncovered()
}



//oTimeLine.ShowUncovered()


#-->
#              ╞===BUSY====╡                          
#          ╞===BUSY====╡        ╞=BUSY=╡              
# |////////●───●───────●───●////◉──────●///////////○─►
#          1   2       3   4   5-6     7                     
# 
# ╭────┬─────────────────────┬───────┬────────────────╮
# │ No │      Timepoint      │ Label │  Description   │
# ├────┼─────────────────────┼───────┼────────────────┤
# │    │ 2024-01-01 00:00:00 │       │ Timeline start │
# │  1 │ 2024-03-01 00:00:00 │ BUSY  │ Start of BUSY  │
# │  2 │ 2024-04-01 00:00:00 │ BUSY  │ Start of BUSY  │
# │  3 │ 2024-05-31 23:59:59 │ BUSY  │ End of BUSY    │
# │  4 │ 2024-06-30 23:59:59 │ BUSY  │ End of BUSY    │
# │  5 │ 2024-08-01 00:00:00 │ BUSY  │ Start of BUSY  │
# │  6 │ 2024-08-30 23:59:59 │ BUSY  │ End of BUSY    │
# │    │ 2024-12-31 23:59:59 │       │ Timeline end   │
# ╰────┴─────────────────────┴───────┴────────────────╯

pf()
# Executed in 0.22 second(s) in Ring 1.24

#---------------------------#
#  Distance Calculations    #
#---------------------------#
