# Narrative
# --------
# Adding and removing lanes
#
# Extracted from stzlistoftimelinestest.ring, block #4.

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddLane("Team B")
	AddLane("Resources")

	? NumberOfLanes()
	#--> 3

	? @@( Lanes() )
	#--> [ "TEAM A", "TEAM B", "RESOURCES" ]

	? HasLane("team b")  # Case-insensitive if implemented
	#--> TRUE

	RemoveLane("Resources")
	? NumberOfLanes()
	#--> 2

	? HasLane("Resources")
	#--> FALSE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#--------------------------------#
#  Adding Points/Spans to Lanes  #
#--------------------------------#
