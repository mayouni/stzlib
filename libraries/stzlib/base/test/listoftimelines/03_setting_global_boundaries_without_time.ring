# Narrative
# --------
# Setting global boundaries without time
#
# Extracted from stzlistoftimelinestest.ring, block #3.

load "../../stzBase.ring"


pr()

o1 = new stzTimeLines( @{
	:Lanes = [ "Project1", "Project2" ],
	:Start = "2024-01-01",
	:End   = "2024-03-20"
} )

o1.AddPointToLane("Project1", "EVENT", "2024-03-15")  # Time added automatically
? o1.Lane("Project1").Point("EVENT")
#--> 2024-03-15 00:00:00

o1.AddSpanToLane("Project2", "WEEK", "2024-03-01", "2024-03-07")
? @@( o1.Lane("Project2").Span("WEEK") )
#--> [ "2024-03-01 00:00:00", "2024-03-07 00:00:00" ]

o1.SetGlobalStart("2024-01-01")
? o1.GlobalStart()
#--> 2024-01-01 00:00:00

? @@NL( o1.Content() ) + NL
#--> Similar structure as above with added points/spans in respective lanes

pf()
# Executed in 0.02 second(s) in Ring 1.24

#-------------------------#
#  Lane Management        #
#-------------------------#
