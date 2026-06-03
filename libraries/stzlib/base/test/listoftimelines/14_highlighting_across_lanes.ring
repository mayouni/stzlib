# Narrative
# --------
# Highlighting across lanes
#
# Extracted from stzlistoftimelinestest.ring, block #14.

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointToLane("Team A", "HR-EVAL", "2024-03-15")
	AddSpanToLane("Team B", "HR-EVAL", "2024-08-01", "2024-08-31")

	VizFind("HR-EVAL")
	#--> Shows highlighted '█' in both lanes for "HR-EVAL"
}

pf()
# Executed in 0.05 second(s) in Ring 1.24

#-------------------------#
#  Conversion and Misc    #
#-------------------------#
