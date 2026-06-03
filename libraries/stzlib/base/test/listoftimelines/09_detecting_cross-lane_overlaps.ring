# Narrative
# --------
# Detecting cross-lane overlaps
#
# Extracted from stzlistoftimelinestest.ring, block #9.
#ERR Error (C8) : Parentheses ')' is missing

load "../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddSpanToLane("Dev", "CODING", "2024-04-01", "2024-05-15")
	AddSpanToLane("QA", "TESTING", "2024-05-10", "2024-06-01")

	? @@( CrossLaneOverlaps() )
	#--> [ [ [ "DEV", "QA" ], "CODING", "TESTING", 432000 ] ]  # 5 days in seconds
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#-------------------------------------#
#  Blocking Regions in Specific Lanes #
#-------------------------------------#
