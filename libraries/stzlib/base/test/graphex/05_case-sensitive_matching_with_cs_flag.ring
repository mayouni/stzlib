# Narrative
# --------
# Case-sensitive matching with @cs: flag
#
# Extracted from stzgraphextest.ring, block #5.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("CaseSensitive")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "start")
	AddEdgeXT(:a, :b, "flows")
}

# With @cs:, exact case required
oGx = new stzGraphex("{@cs:@Node(Start)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (exact "Start" exists)

oGx2 = new stzGraphex("{@cs:@Node(start)}", oGraph)
? oGx2.Match(oGraph)
#--> TRUE (exact "start" exists)

oGx3 = new stzGraphex("{@cs:@Node(START)}", oGraph)
? oGx3.Match(oGraph)
#--> FALSE (no "START" node)

pf()
