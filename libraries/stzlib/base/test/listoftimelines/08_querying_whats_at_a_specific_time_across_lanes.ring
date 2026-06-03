# Narrative
# --------
# Querying what's at a specific time across lanes
#
# Extracted from stzlistoftimelinestest.ring, block #8.

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddPointToLane("Team A", "EVENT1", "2024-03-15 10:00:00")
	AddSpanToLane("Team B", "PHASE1", "2024-03-10", "2024-03-20")

	? @@NL( WhatsAt("2024-03-15 10:00:00") )
	#--> [
	#	[ "lane", "TEAM A" ],
	#	[ "events", [ [ "EVENT1", "point" ] ] ],
	#	[ "lane", "TEAM B" ],
	#	[ "events", [ [ "PHASE1", "span" ] ] ]
	# ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
