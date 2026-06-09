# Narrative
# --------
# Test longer token prefixes parsed correctly
#
# Extracted from stzgraphextest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Props")
oGraph {
	AddNodeXT(:a, "Start", ["type" = "entry", "priority" = 1])
	AddNodeXT(:b, "End", ["type" = "exit"])
	AddEdgeXT(:a, :b, "flows")
}

# Test @NodeProperty (longer prefix) vs @Node
oGx = new stzGraphex("{@NodeProperty(type)}", oGraph)
oGx.EnableDebug()
? oGx.Match(oGraph)
#--> Should parse as "nodeproperty" not "node"

pf()
