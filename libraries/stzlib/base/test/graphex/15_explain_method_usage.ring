# Narrative
# --------
# Explain method usage
#
# Extracted from stzgraphextest.ring, block #15.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Sample")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "flows")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge(flows) -> @Node(End)}", oGraph)
? "=== Pattern Explanation ==="
? @@(oGx.Explain())

pf()
