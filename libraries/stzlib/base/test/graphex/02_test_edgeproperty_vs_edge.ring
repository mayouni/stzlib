# Narrative
# --------
# Test @EdgeProperty vs @Edge
#
# Extracted from stzgraphextest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("EdgeProps")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddEdgeXTT(:a, :b, "connects", [:weight = 5])
}

oGx = new stzGraphex("{@Node -> @EdgeProperty(weight) -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> Should parse as "edgeproperty" not "edge"

pf()
