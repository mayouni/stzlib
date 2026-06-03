# Narrative
# --------
# Renaming labels in specific lanes
#
# Extracted from stzlistoftimelinestest.ring, block #7.

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointsToLane("Team A", [
		[ "HR-EVAL", "2024-03-15 10:00:00" ],
		[ "KICKOFF", "2024-05-16 14:30:00" ]
	])

	AddSpansToLane("Team B", [
		[ "PREP", "2024-03-15", "2024-05-15" ],
		[ "HR-EVAL", "2024-11-01", "2024-11-25" ]
	])

	RenameLabelInLane("Team A", "HR-EVAL", "PERF-REVIEW")
	RenameLabelInLane("Team B", "PREP", "PREPARATION")

	? @@NL( Content() )  # Show updated labels in respective lanes
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#-------------------------#
#  Querying Across Lanes  #
#-------------------------#
