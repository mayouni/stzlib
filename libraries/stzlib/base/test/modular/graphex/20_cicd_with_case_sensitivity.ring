# Narrative
# --------
# CI/CD with case sensitivity
#
# Extracted from stzgraphextest.ring, block #20.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("CICD")
oGraph {
	AddNodeXT(:code, "code")  # lowercase
	AddNodeXT(:build, "BUILD")  # uppercase
	AddNodeXT(:test, "Test")  # mixed
	AddNodeXT(:deploy, "Deploy")
	AddEdgeXT(:code, :build, "compiles")
	AddEdgeXT(:build, :test, "validates")
	AddEdgeXT(:test, :deploy, "releases")
}

# Case-insensitive pattern
oGx = new stzGraphex("{@Node(Code) -> @Edge(compiles) -> @Node(Build)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (case-insensitive)

# Case-sensitive pattern
oGx2 = new stzGraphex("{@cs:@Node(BUILD) -> @Edge -> @Node(Test)}", oGraph)
? oGx2.Match(oGraph)
#--> TRUE (exact case match)

pf()
