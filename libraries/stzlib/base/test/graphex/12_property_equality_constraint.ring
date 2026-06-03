# Narrative
# --------
# Property equality constraint
#
# Extracted from stzgraphextest.ring, block #12.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Roles")
oGraph {
	AddNodeXT(:u1, "User1", ["role" = "admin"])
	AddNodeXT(:u2, "User2", ["role" = "user"])
	AddNodeXT(:u3, "User3", ["role" = "admin"])
}

# Match admin users
oGx = new stzGraphex("{@Node{role:=:admin}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()
