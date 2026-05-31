# Narrative
# --------
# Finding spans overlapping a point
#
# Extracted from stztimelinetest.ring, block #17.

load "../../../stzBase.ring"

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("PROJECT_B", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-08-31 23:59:59")

	? @@( SpansOverlapping("2024-03-15 12:00:00") )
	#--> [ "PROJECT_A", "PROJECT_B" ]

	? @@( SpansContaining("2024-07-15 12:00:00") ) + NL
	#--> [ "PROJECT_C" ]

}

oTimeLine.Show()
#-->
'
         ╞═PROJECT_B═╡                            
     ╞═PROJECT_A═╡   ╞═PROJECT_C══╡                 
│────◉───◉───────◉───◉────────────◉─────────────────○─►
     1   2       3  4-5           6                 

╭────┬─────────────────────┬───────────┬────────────────────╮
│ No │      Timepoint      │   Label   │    Description     │
├────┼─────────────────────┼───────────┼────────────────────┤
│    │ 2024-01-01 00:00:00 │           │ Timeline start     │
│  1 │ 2024-02-01 00:00:00 │ PROJECT_A │ Start of PROJECT_A │
│  2 │ 2024-03-01 00:00:00 │ PROJECT_B │ Start of PROJECT_B │
│  3 │ 2024-04-30 23:59:59 │ PROJECT_A │ End of PROJECT_A   │
│  4 │ 2024-05-31 23:59:59 │ PROJECT_B │ End of PROJECT_B   │
│  5 │ 2024-06-01 00:00:00 │ PROJECT_C │ Start of PROJECT_C │
│  6 │ 2024-08-31 23:59:59 │ PROJECT_C │ End of PROJECT_C   │
│    │ 2024-12-31 23:59:59 │           │ Timeline end       │
╰────┴─────────────────────┴───────────┴────────────────────╯
'

pf()
# Executed in 0.19 second(s) in Ring 1.24

#-----------------------#
#  Overlap Detection    #
#-----------------------#
