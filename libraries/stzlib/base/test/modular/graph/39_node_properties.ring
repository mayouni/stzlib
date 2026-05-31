# Narrative
# --------
# Node properties
#
# Extracted from stzgraphtest.ring, block #39.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("propertiesTest")
oGraph {
	AddNodeXT("n1", "Node 1")
	
	SetNodeProperties("n1", [:owner = "alice", :created = "2024-01-01"])
	
	? @@( NodeProperties("n1") )
	#--> [ "owner", "created" ]

	? @@( NodePropertiesXT("n1") )
	#--> [:owner = "alice", :created = "2024-01-01"]
	
	SetNodeProperty("n1", "modified", "2024-01-15")
	
	? NodeProperty("n1", "modified")
	#--> "2024-01-15"
	
	RemoveNodeProperties("n1")
	? @@( NodeProperties("n1") )
	#--> []
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
