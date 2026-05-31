# Narrative
# --------
# Adding points to specific lanes
#
# Extracted from stzlistoftimelinestest.ring, block #5.

load "../../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddPointToLane("Team A", "NEW_YEAR", "2024-01-01 00:00:00")
	AddPointToLane("Team B", "VALENTINE", "2024-02-14 00:00:00")
	AddPointToLane("Team A", "SUMMER", "2024-06-21 00:00:00")

	? Lane("Team A").CountPoints()
	#--> 2

	? @@( Lane("Team A").PointNames() )
	#--> [ "NEW_YEAR", "SUMMER" ]

	? Lane("Team B").Point("VALENTINE")
	#--> 2024-02-14 00:00:00

	? Lane("Team A").HasPoint("summer")
	#--> TRUE
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
