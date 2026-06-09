# Narrative
# --------
# Set multiple properties
#
# Extracted from stzgraphquerytest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("test")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30])
}

StzGraphQueryQ(oGraph) {
	Match([:node = "n", :where = [:id, "=", "alice"]])
	Set("n.age", [:to = 31])
	Set("n.city", [:to = "Paris"])
	Select("n")
}

? oGraph.NodeProperty("alice", "age")
#--> 31

? oGraph.NodeProperty("alice", "city")
#--> "Paris"

pf()
# Executed in 0.01 second(s) in Ring 1.26

#-------------------#
#  DELETE PATTERNS  #
#-------------------#
