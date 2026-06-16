# Narrative
# --------
# Property value comparison (greater than)
#
# Extracted from stzgraphextest.ring, block #10.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Users")
oGraph {
	AddNodeXTT(:u1, "Alice", [:age = 30])
	AddNodeXTT(:u2, "Bob", [:age = 20])
	AddNodeXTT(:u3, "Charlie", [:age = 35])
}

# Match nodes with age > 25
oGx = new stzGraphex("{@Node{age:>:25}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Alice and Charlie match)

pf()
