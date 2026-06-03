# Narrative
# --------
# Show uncovered across lanes
#
# Extracted from stzlistoftimelinestest.ring, block #13.
#ERR Error (C8) : Parentheses ')' is missing

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddSpanToLane("Dev", "BUSY", "2024-03-01", "2024-05-31")
	AddSpanToLane("QA", "BUSY", "2024-08-01", "2024-09-20")

	? ShowUncovered()
	#--> Visualization with '/' for uncovered in each lane
}

pf()
# Executed in 0.05 second(s) in Ring 1.24
