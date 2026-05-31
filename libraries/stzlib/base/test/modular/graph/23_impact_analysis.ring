# Narrative
# --------
# Impact Analysis
#
# Extracted from stzgraphtest.ring, block #23.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("ImpactTest")
oGraph {
	AddNode("db")
	AddNode("api")
	AddNode("worker1")
	AddNode("worker2")
	
	Connect("db", "api")
	Connect("api", "worker1")
	Connect("api", "worker2")
	
	? ImpactOf("api")
	#--> 2

	? @@( FailureScope("api") )
	#--> ["worker1", "worker2"]

	? @@( MostCriticalNodes(2) )
	#--> ["api", "db"]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
