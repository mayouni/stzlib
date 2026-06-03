# Narrative
# --------
# Basic show with multiple lanes
#
# Extracted from stzlistoftimelinestest.ring, block #12.
#ERR Error (C8) : Parentheses ')' is missing

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddSpanToLane("Team A", "PROJECT", "2024-03-01", "2024-05-31")
	AddPointToLane("Team B", "HR-EVAL", "2024-03-15")

	? Show()
	#--> Multi-lane ASCII visualization with lanes labeled on left
}

pf()
# Executed in 0.05 second(s) in Ring 1.24
