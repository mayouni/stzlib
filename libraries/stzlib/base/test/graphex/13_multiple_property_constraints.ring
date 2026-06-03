# Narrative
# --------
# Multiple property constraints
#
# Extracted from stzgraphextest.ring, block #13.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Complex")
oGraph {
	AddNodeXT(:u1, "Alice", ["age" = 30, "score" = 85])
	AddNodeXT(:u2, "Bob", ["age" = 25, "score" = 90])
	AddNodeXT(:u3, "Charlie", ["age" = 35, "score" = 75])
}

# Match nodes: age > 26 AND score > 80
oGx = new stzGraphex("{@Node{age:>:26;score:>:80}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Alice matches both)

pf()
