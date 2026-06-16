# Narrative
# --------
# Property value comparison (less than)
#
# Extracted from stzgraphextest.ring, block #11.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Products")
oGraph {
	AddNodeXTT(:p1, "ItemA", [:price = 10])
	AddNodeXTT(:p2, "ItemB", [:price = 50])
	AddNodeXTT(:p3, "ItemC", [:price = 5])
}

# Match items with price < 15
oGx = new stzGraphex("{@Node{price:<:15}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (ItemA and ItemC match)

pf()
