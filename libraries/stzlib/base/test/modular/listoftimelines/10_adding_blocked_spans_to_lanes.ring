# Narrative
# --------
# Adding blocked spans to lanes
#
# Extracted from stzlistoftimelinestest.ring, block #10.

load "../../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Resources", "Team" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddBlockedSpanToLane("Resources", "DOWNTIME", "2024-06-15 09:00:00", "2024-06-15 17:00:00")
	// AddPointToLane("Team", "EVENT", "2024-06-15 12:00:00")  # OK, since block is in different lane

	AddPointToLane("Resources", "TASK", "2024-06-15 12:00:00")
	#--> ERROR: Point 'TASK' falls within a blocked span in lane 'Resources'
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
