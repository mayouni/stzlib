# Narrative
# --------
# Complex example with multiple lanes, blocks, and visualization
#
# Extracted from stzlistoftimelinestest.ring, block #17.

load "../../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA", "Resources" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {

	# Spans in lanes
	AddSpanToLane("Dev", "CODING", "2024-01-01", "2024-06-30")
	AddSpanToLane("QA", "TESTING", "2024-03-01", "2024-09-30")
	AddSpanToLane("Resources", "AVAILABLE", "2024-05-01", "2024-12-31")

	# Blocked spans
	AddBlockedSpanToLane("Resources", "DOWNTIME", "2024-07-01", "2024-07-15")

	# Points
	AddPointToLane("Dev", "KICKOFF", "2024-01-05 09:00:00")
	AddPointToLane("QA", "MEETING", "2024-05-10 11:00:00")

	? Show()
	#--> Multi-lane visualization with spans, points, and blocks

	? @@NL( UncoveredPeriodsPerLane() )
	#--> List of uncovered periods for each lane
}

pf()
# Executed in 0.35 second(s) in Ring 1.24
