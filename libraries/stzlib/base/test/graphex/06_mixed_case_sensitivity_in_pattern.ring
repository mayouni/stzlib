# Narrative
# --------
# Mixed case sensitivity in pattern
#
# Extracted from stzgraphextest.ring, block #6.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Mixed")
oGraph {
	AddNodeXT(:a, "User")
	AddNodeXT(:b, "ADMIN")
	AddEdgeXT(:a, :b, "Promotes")
}

# Case-sensitive on first node, insensitive on second
oGx = new stzGraphex("{@cs:@Node(User) -> @Edge -> @Node(admin)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  ENHANCEMENT 3: CACHING TESTS
#============================#
