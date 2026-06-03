# Narrative
# --------
# Complex timeline with overlapping spans
#
# Extracted from stztimelinetest.ring, block #37.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_B", "2024-04-01 00:00:00", "2024-07-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-09-30 23:59:59")

	AddPoint("MILESTONE1", "2024-03-15 00:00:00")
	AddPoint("MILESTONE2", "2024-08-15 00:00:00")
}

oTimeLine.Show()
#-->
'
                     ╞═══PROJECT_C════╡             
             ╞═══PROJECT_B════╡                     
     ╞MILESTONE1_A═══╡     MILESTONE2               
|────●─────●─●───────●────────●─●─────●──────────○─►
     1     2 3      4-5       6 7     8             

╭────┬─────────────────────┬────────────┬────────────────────╮
│ No │      Timepoint      │   Label    │    Description     │
├────┼─────────────────────┼────────────┼────────────────────┤
│    │ 2024-01-01 00:00:00 │            │ Timeline start     │
│  1 │ 2024-02-01 00:00:00 │ PROJECT_A  │ Start of PROJECT_A │
│  2 │ 2024-03-15 00:00:00 │ MILESTONE1 │ MILESTONE1 event   │
│  3 │ 2024-04-01 00:00:00 │ PROJECT_B  │ Start of PROJECT_B │
│  4 │ 2024-05-31 23:59:59 │ PROJECT_A  │ End of PROJECT_A   │
│  5 │ 2024-06-01 00:00:00 │ PROJECT_C  │ Start of PROJECT_C │
│  6 │ 2024-07-31 23:59:59 │ PROJECT_B  │ End of PROJECT_B   │
│  7 │ 2024-08-15 00:00:00 │ MILESTONE2 │ MILESTONE2 event   │
│  8 │ 2024-09-30 23:59:59 │ PROJECT_C  │ End of PROJECT_C   │
│    │ 2024-12-31 23:59:59 │            │ Timeline end       │
╰────┴─────────────────────┴────────────┴────────────────────╯
'

pf()
# Executed in 0.11 second(s) in Ring 1.24

#------------------------------#
#  Error Handling & Validation #
#------------------------------#

#---

pr()

o1 = new stzTimeLine("2024-10-10 12:10:10", "18:59:59")
#--> ERROR: Invalid input in pEnd! Time specified without a date.

pf()
