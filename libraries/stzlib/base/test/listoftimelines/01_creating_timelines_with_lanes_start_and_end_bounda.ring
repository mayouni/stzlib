# Narrative
# --------
# Creating timelines with lanes, start, and end boundaries
#
# Extracted from stzlistoftimelinestest.ring, block #1.

load "../../stzBase.ring"

pr()

oTimeLines = new stzTimeLines([
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
])

oTimeLines {
	? GlobalStart()
	#--> 2024-01-01 00:00:00

	? GlobalEnd()
	#--> 2024-12-31 23:59:59

	? Duration()
	#--> 31622399 (seconds)

	? DurationQ().ToHuman()
	#--> 1 year

	? NumberOfLanes()
	#--> 2

	? @@( Lanes() )
	#--> [ "TEAM A", "TEAM B" ]  # Note: labels uppercased if applicable, but lane names may vary
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
