# Narrative
# --------
# Parentheses content before lowercasing
#
# Extracted from stzgraphextest.ring, block #18.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Labels")
oGraph {
	AddNodeXT(:a, "CamelCaseLabel")
	AddNodeXT(:b, "UPPERCASE")
	AddEdgeXT(:a, :b, "MixedCase")
}

# All labels should be extracted before lowercasing
oGx = new stzGraphex("{@Node(CamelCaseLabel) -> @Edge(MixedCase) -> @Node(UPPERCASE)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  ORIGINAL TESTS (UPDATED)
#============================#
