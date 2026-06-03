# Narrative
# --------
# Adding multiple points and spans to lanes
#
# Extracted from stzlistoftimelinestest.ring, block #6.
#ERR Error (C8) : Parentheses ')' is missing

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddPointsToLane("Dev", [
		[ "CODE_REVIEW", "2024-03-15 10:00:00" ],
		[ "CODE_REVIEW", "2024-05-16 14:30:00" ]
	])

	AddSpansToLane("QA", [
		[ "TEST_PHASE", "2024-04-01", "2024-06-30" ]
	])

	? Lane("Dev").CountPoints()
	#--> 2

	? Lane("QA").CountSpans()
	#--> 1
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
