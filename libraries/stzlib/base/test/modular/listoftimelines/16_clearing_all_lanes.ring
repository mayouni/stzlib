# Narrative
# --------
# Clearing all lanes
#
# Extracted from stzlistoftimelinestest.ring, block #16.

load "../../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointToLane("Team A", "EVENT", "2024-03-15")

	Clear()
	? Lane("Team A").CountPoints()
	#--> 0
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
