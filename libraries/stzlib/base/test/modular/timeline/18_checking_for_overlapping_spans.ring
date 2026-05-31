# Narrative
# --------
# Checking for overlapping spans
#
# Extracted from stztimelinetest.ring, block #18.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("SPAN_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("SPAN_B", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}

? oTimeLine.HasOverlaps()
#--> TRUE

oTimeLine.ShowShort()
#-->
'
        ╞══SPAN_B═══╡                              
     ╞══SPAN_A═══╡                                  
│────●───●───────●───●─────────────────────────────○─►
     1   2       3   4                              
'

pf()
# Executed in 0.06 second(s) in Ring 1.24
