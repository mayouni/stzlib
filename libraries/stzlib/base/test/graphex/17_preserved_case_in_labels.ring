# Narrative
# --------
# Preserved case in labels
#
# Extracted from stzgraphextest.ring, block #17.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Case")
oGraph {
	AddNodeXT(:a, "StartNode")
	AddNodeXT(:b, "EndNode")
	AddEdgeXT(:a, :b, "FlowsTo")
}

# Label should preserve exact case
oGx = new stzGraphex("{@Node(StartNode) -> @Edge(FlowsTo) -> @Node(EndNode)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (case preserved correctly)

pf()
