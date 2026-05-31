# Narrative
# --------
# Test @EdgeProperty vs @Edge
#
# Extracted from stzgraphextest.ring, block #2.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("EdgeProps")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddEdgeXT(:a, :b, "connects", ["weight" = 5])
}

oGx = new stzGraphex("{@Node -> @EdgeProperty(weight) -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> Should parse as "edgeproperty" not "edge"

pf()
