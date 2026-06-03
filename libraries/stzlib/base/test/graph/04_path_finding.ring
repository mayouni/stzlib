# Narrative
# --------
# Path Finding
#
# Extracted from stzgraphtest.ring, block #4.
#ERR panic: integer part of floating point value out of bounds

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("PathTest")
oGraph {
	AddNode("start")
	AddNode("middle")
	AddNode("end")

	Connect("start", :to = "middle")
	Connect("middle", :to = "end")

	? PathExists("start", "end")      #--> TRUE
	? PathExists("start", "isolated") #--> FALSE

	? @@NL( PathsXT("start", "end") )
	#--> [ ["start", "middle", "end"] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
