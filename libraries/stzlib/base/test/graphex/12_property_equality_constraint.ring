# Narrative
# --------
# Property equality constraint
#
# Extracted from stzgraphextest.ring, block #12.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Roles")
oGraph {
	AddNodeXTT(:u1, "User1", [:role = "admin"])
	AddNodeXTT(:u2, "User2", [:role = "user"])
	AddNodeXTT(:u3, "User3", [:role = "admin"])
}

# Match admin users
oGx = new stzGraphex("{@Node{role:=:admin}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()
