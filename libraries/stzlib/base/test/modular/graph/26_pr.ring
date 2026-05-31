# Narrative
# --------
# pr()
#
# Extracted from stzgraphtest.ring, block #26.

load "../../../stzBase.ring"


oGraph = new stzGraph("EdgeManagementTest")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")

	# Create multiple edges to different targets
	ConnectXTT("A", "B", "route1", [:speed = "fast"])
	ConnectXTT("A", "C", "route2", [:speed = "slow"])
	ConnectXTT("B", "C", "route3", [:speed = "medium"])

	? EdgeCountBetween("A", "B")  #--> 1
	? EdgeCountBetween("A", "C")  #--> 1

	? @@NL( EdgesBetween("A", "B") )
	#--> [
	# 	["A", "route1", "B"]
	# ]

	? @@NL( EdgesBetween("A", "C") )
	#--> [
	# 	["A", "route2", "C"]
	# ]

	# Remove specific edge by label
	RemoveEdgeByLabel("A", "C", "route2")
	? EdgeCountBetween("A", "C")  #--> 0

}

pf()
# Executed in 0.01 second(s) in Ring 1.24
