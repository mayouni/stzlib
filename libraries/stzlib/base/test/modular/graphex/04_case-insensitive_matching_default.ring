# Narrative
# --------
# Case-insensitive matching (default)
#
# Extracted from stzgraphextest.ring, block #4.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Mixed")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "PROCESS")
	AddNodeXT(:c, "end")
	AddEdgeXT(:a, :b, "Flows")
	AddEdgeXT(:b, :c, "COMPLETES")
}

# Without @cs:, should match any case
oGx = new stzGraphex("{@Node(start) -> @Edge(flows) -> @Node(process)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (case-insensitive by default)

pf()
