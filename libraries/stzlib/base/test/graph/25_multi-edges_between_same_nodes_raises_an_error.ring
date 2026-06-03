# Narrative
# --------
# Multi-Edges Between Same Nodes : Raises an error
#
# Extracted from stzgraphtest.ring, block #25.

load "../../stzBase.ring"

pr()

oGraph = new stzGraph("MultiEdgeTest")
oGraph {
	AddNode("source")
	AddNode("target")

	ConnectXTT("source", "target", "primary", [:priority = "high"])
	ConnectXTT("source", "target", "backup", [:priority = "low"])
	#--> Edge already exists between 'source' and 'target'!
}
#TODO : Should we support multi-edges?

pf()
