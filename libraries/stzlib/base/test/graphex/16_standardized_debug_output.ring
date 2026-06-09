# Narrative
# --------
# Standardized debug output
#
# Extracted from stzgraphextest.ring, block #16.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Debug")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddEdgeXT(:a, :b, "connects")
}

oGx = new stzGraphex("{@Node(A) -> @Edge -> @Node(B)}", oGraph)
oGx.EnableDebug()
? oGx.Match(oGraph)
#--> Shows consistent debug messages

pf()

#============================#
#  ENHANCEMENT 6: VALUE PRESERVATION TESTS
#============================#
