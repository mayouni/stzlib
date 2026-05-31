# Narrative
# --------
# Converting to single TimeLine
#
# Extracted from stzlistoftimelinestest.ring, block #15.

load "../../../stzBase.ring"


pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointToLane("Dev", "EVENT", "2024-03-15")
	AddSpanToLane("QA", "TEST", "2024-04-01", "2024-04-30")

	oMerged = ToTimeLine()
	? oMerged.Point("DEV-EVENT")
	#--> 2024-03-15 00:00:00

	? @@( oMerged.Span("QA-TEST") )
	#--> [ "2024-04-01 00:00:00", "2024-04-30 00:00:00" ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
