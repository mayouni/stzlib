# Narrative
# --------
# Negation with case sensitivity
#
# Extracted from stzgraphextest.ring, block #22.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Clean")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Success")
	AddNodeXT(:c, "error")  # lowercase
	AddEdgeXT(:a, :b, "proceeds")
}

# Case-insensitive negation
oGx = new stzGraphex("{@Node(Start) -> @Edge -> @!Node(Error)}", oGraph)
? oGx.Match(oGraph)
#--> FALSE (matches "error" case-insensitively)

# Case-sensitive negation
oGx2 = new stzGraphex("{@cs:@Node(Start) -> @Edge -> @!Node(Error)}", oGraph)
? oGx2.Match(oGraph)
#--> TRUE ("Error" != "error" in case-sensitive mode)

pf()
