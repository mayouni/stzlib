# Narrative
# --------
# Checking blocks in lanes
#
# Extracted from stzlistoftimelinestest.ring, block #11.

load "../../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Server" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddBlockedSpanToLane("Server", "BLACKOUT", "2024-08-01 00:00:00", "2024-08-08 23:59:59")

	if IsBlockedInLane("Server", "2024-08-05 14:30:00")
		? "Cannot add event during blackout in Server lane"
	ok
	#--> Cannot add event during blackout in Server lane
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#-------------------------#
#  Visualization          #
#-------------------------#
